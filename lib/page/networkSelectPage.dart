import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:polka_wallet/common/components/addressIcon.dart';
import 'package:polka_wallet/common/components/roundedCard.dart';
import 'package:polka_wallet/common/consts/settings.dart';
import 'package:polka_wallet/page/account/createAccountEntryPage.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';
import 'package:polka_wallet/store/account.dart';
import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/store/settings.dart';
import 'package:polka_wallet/utils/format.dart';
import 'package:polka_wallet/utils/i18n/index.dart';

class NetworkSelectPage extends StatefulWidget {
  NetworkSelectPage(this.store, this.changeTheme);

  static final String route = '/network';
  final AppStore store;
  final Function changeTheme;

  @override
  _NetworkSelectPageState createState() =>
      _NetworkSelectPageState(store, changeTheme);
}

class _NetworkSelectPageState extends State<NetworkSelectPage> {
  _NetworkSelectPageState(this.store, this.changeTheme);

  final AppStore store;
  final Function changeTheme;

  EndpointData _selectedNetwork;
  bool _networkChanging = false;

  Future<void> _reloadNetwork() async {
    setState(() {
      _networkChanging = true;
    });
    await store.settings.setBestNode(info: _selectedNetwork.info);
    store.settings.loadNetworkStateCache();
    store.settings.setNetworkLoading(true);
    store.assets.clearTxs();
    store.staking.clearState();
    webApi.launchWebview();
    changeTheme();
    if (mounted) {
      setState(() {
        _networkChanging = false;
      });
    }
    Navigator.of(context).pop();
  }

  List<Widget> _buildAccountList() {
    Color primaryColor = Theme.of(context).primaryColor;
    bool isAcala = store.settings.endpoint.info == networkEndpointAcala.info;
    List<Widget> res = [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            _selectedNetwork.info.toUpperCase(),
            style: Theme.of(context).textTheme.headline4,
          ),
          IconButton(
            icon: Image.asset(
                'assets/images/assets/plus_${isAcala ? 'indigo' : 'pink'}.png'),
            color: primaryColor,
            onPressed: () =>
                Navigator.of(context).pushNamed(CreateAccountEntryPage.route),
          )
        ],
      ),
    ];
    bool isCurrentNetwork =
        _selectedNetwork.info == store.settings.endpoint.info;

    List<AccountData> accounts = [store.account.currentAccount];
    accounts.addAll(store.account.optionalAccounts);
//    print(store.account.pubKeyAddressMap);
    res.addAll(accounts.map((i) {
      String address =
          store.account.pubKeyAddressMap[_selectedNetwork.ss58][i.pubKey];
      return RoundedCard(
        border: address == store.account.currentAddress
            ? Border.all(color: Theme.of(context).primaryColorLight)
            : Border.all(color: Theme.of(context).cardColor),
        margin: EdgeInsets.only(bottom: 16),
        child: ListTile(
          leading: AddressIcon('', pubKey: i.pubKey),
          title: Text(i.name),
          subtitle: Text(Fmt.address(address ?? 'address xxxx')),
          onTap: _networkChanging
              ? null
              : () {
                  if (address == store.account.currentAddress) return;

                  /// set current account
                  store.account.setCurrentAccount(i);
                  // refresh balance
                  store.assets.loadAccountCache();

                  if (store.settings.endpoint.info ==
                      networkEndpointKusama.info) {
                    // refresh user's staking info
                    store.staking.loadAccountCache();
                  }

                  if (store.settings.endpoint.info ==
                      networkEndpointAcala.info) {
                    store.acala.loadCache();
                  }

                  if (isCurrentNetwork) {
                    /// reload account info
                    webApi.assets.fetchBalance(i.pubKey);
                    Navigator.of(context).pop();
                  } else {
                    /// set new network and reload web view
                    _reloadNetwork();
                  }
                },
        ),
      );
    }).toList());
    return res;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _selectedNetwork = store.settings.endpoint;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map doc = I18n.of(context).home;
    return Scaffold(
      appBar: AppBar(
        title: Text(doc['setting.network']),
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          if (_selectedNetwork == null) return Container();
          return Row(
            children: <Widget>[
              // left side bar
              Container(
                padding: EdgeInsets.fromLTRB(16, 16, 0, 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8.0, // has the effect of softening the shadow
                      spreadRadius: 2.0, // ha
                    )
                  ],
                ),
                child: Column(
                  children:
                      [networkEndpointKusama, networkEndpointAcala].map((i) {
                    String network = i.info;
                    bool isCurrent = network == _selectedNetwork.info;
                    String img =
                        'assets/images/public/$network${isCurrent ? '' : '_gray'}.png';
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.only(right: 8),
                      decoration: isCurrent
                          ? BoxDecoration(
                              border: Border(
                                  right: BorderSide(
                                      width: 2,
                                      color: Theme.of(context).primaryColor)),
                            )
                          : null,
                      child: IconButton(
                        padding: EdgeInsets.all(8),
                        icon: Image.asset(img),
                        onPressed: () {
                          if (!isCurrent) {
                            setState(() {
                              _selectedNetwork = i;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: _buildAccountList(),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
