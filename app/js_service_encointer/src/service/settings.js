import { WsProvider } from '@polkadot/rpc-provider';
import { ApiPromise } from '@polkadot/api';
import { EncointerWorker } from '@encointer/worker-api';
import { options } from '@encointer/node-api';
import WS from 'websocket';
import { pallets } from '../config/consts.js';
import { keyring } from './account.js';

const { w3cwebsocket: WebSocket } = WS;

async function connect (endpoint, configOverride) {
  return new Promise(async (resolve, reject) => {
      console.log(`configOverride: ${JSON.stringify(configOverride)}`);
      const provider = new WsProvider(endpoint);
      try {
        const api = await createApi(provider, configOverride);

        if (!window.api) {
          window.api = api;
          window.send('log', `${endpoint} wss connected success`);
          resolve(endpoint);
        } else {
          window.send('log', `${endpoint} wss connected and ignored`);
          api.disconnect();
        }
      } catch (err) {
        window.send('log', `connect ${endpoint} failed. Error ${err.message}`);
        provider.disconnect();
        resolve(null);
      }
    }
  )
    ;
}

async function connectAll (nodes, configs) {
  let failCount = 0;
  return new Promise((resolve, reject) => {
    let i = 0;
    nodes.forEach(async (endpoint) => {
      const configOverride = configs[i];
      console.log(`Config override for node ${endpoint}: ${JSON.stringify(configOverride)}`);
      i++;
      const provider = new WsProvider(endpoint);
      try {
        const api = await createApi(provider, configOverride);

        if (!window.api) {
          window.api = api;
          window.send('log', `${endpoint} wss connected success`);
          resolve(endpoint);
        } else {
          window.send('log', `${endpoint} wss connected and ignored`);
          api.disconnect();
        }
      } catch (err) {
        window.send('log', `connect ${endpoint} failed. Error ${err}`);
        provider.disconnect();
        failCount += 1;
        if (failCount >= nodes.length) {
          resolve(null);
        }
      }
    });
  });
}

async function setWorkerEndpoint (endpoint, mrenclave) {
  return new Promise(async (resolve, reject) => {
    if (!window.workerEndpoint || window.workerEndpoint !== endpoint) {
      window.workerEndpoint = endpoint;
      window.worker = new EncointerWorker(endpoint, {
        keyring: keyring,
        api: window.api,
        createWebSocket: (url) => new WebSocket(url)
      });
      window.send('log', `set worker endpoint ${endpoint}`);
      window.workerShieldingKey = await window.worker.getShieldingKey();
      window.send('log', 'got the workers shielding key');
      window.mrenclave = mrenclave;
      window.send('log', `set mrenclave ${mrenclave}`);
      resolve(endpoint);
    } else {
      window.send('log', 'already have a workerEndpoint set, ignoring...');
    }
  });
}

function connectedToTeeProxy () {
  return window.workerEndpoint != null;
}

async function getNetworkConst () {
  return api.consts;
}

function changeEndpoint (endpoint) {
  try {
    window.send('log', 'disconnect');
    window.api.disconnect();
  } catch (err) {
    window.send('log', err.message);
  }
  return connect(endpoint);
}

async function subscribeMessage (section, method, params, msgChannel) {
  return api.derive[section][method](...params, (res) => {
    send(msgChannel, res);
  }).then((unsub) => {
    const unsubFuncName = `unsub${msgChannel}`;
    window[unsubFuncName] = unsub;
    return {};
  });
}

async function isConnected () {
  return api.isConnected;
}

async function createApi(wsProvider, configOverride) {
  const api = await ApiPromise.create({
    ...options({
      types: {
        ...configOverride.types !== null ? configOverride.types : {},
        // Todo: integrate MeetupResult into encointer-js
        MeetupResult: {
          _enum: [
            'Ok',
            'VotesNotDependable',
            'MeetupValidationIndexOutOfBounds',
          ]
        },
      }
    }),
    signedExtensions: {
      ChargeAssetTxPayment: {
        extrinsic: {
          tip: 'Compact<Balance>',
          assetId: 'Option<CommunityIdentifier>'
        },
        payload: {}
      }
    },
    provider: wsProvider
  });

  const extTypes = api.registry.getSignedExtensionTypes();
  const extensionExtra = api.registry.getSignedExtensionExtra();

  console.log(`SignedExtensionTypes: ${JSON.stringify(extTypes)}`);
  console.log(`SignedExtensionExtra: ${JSON.stringify(extensionExtra)}`);

  if (configOverride.pallets !== null) {
    Object.assign(pallets, configOverride.pallets);
  }
  window.send('log', `overwritten pallet config: ${JSON.stringify(pallets)}`);

  const chainProperties = api.registry.getChainProperties();
  window.send('log', `chain properties: ${chainProperties}`);

  // Hardcode SS58-prefix to 42, see https://github.com/encointer/encointer-wallet-flutter/issues/567
  const properties = {
    ss58Format: 42,
    tokenDecimals: chainProperties.tokenDecimals,
    tokenSymbol: chainProperties.tokenSymbol
  };

  window.send('log', `ss58 overwritten chain properties: ${JSON.stringify(properties)}`);
  api.registry.setChainProperties(properties);
  return api;
}

export default {
  connect,
  connectAll,
  changeEndpoint,
  getNetworkConst,
  setWorkerEndpoint,
  connectedToTeeProxy,
  subscribeMessage,
  isConnected
};
