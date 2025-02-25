import 'dart:io';

import 'package:encointer_wallet/service/ipfs/http_api.dart';
import 'package:encointer_wallet/service/log/log_service.dart';

const mockIcon = '<svg viewBox="0 0 132.09 131.85" '
    'xmlns="http://www.w3.org/2000/svg"><circle cx="65.4" '
    'cy="66.45" fill="#67c4e7" r="65.4" transform= '
    '"matrix(.37233994 -.92809642 .92809642 .37233994 -20.62 102.4)"/> '
    '<path d="m65.46.5a65.43 65.43 0 0 0 -60 41.05l83.54 85.37a65.25 65.25 0 '
    '0 0 -23.54-126.42z" fill="#fff" stroke="#67c4e7" stroke-miterlimit="10"/> '
    '<path d="m64.76 22.3 5.68 13.54-30.93-13.54z"/><path d="m85.59 22.3 11.04 11.28v-11.28z"/> '
    '<path d="m82.28 48.09 12.14 11.29v8.38l-23.98 14.79-13.57-6.09 13.57 9.67 '
    '26.19-11.6 7.26 8.06v-10.32l-4.42-4.35v-8.87l4.42-5.8v-5.16z"/> '
    '<path d="m97.62 95.38-12.03 11.17-8.84-11.17z"/></svg>';

class MockIpfs extends Ipfs {
  MockIpfs(String gateway) : super(gateway: gateway);

  @override
  Future<void> getJson(String cid) async {
    Log.d('unimplemented getJson', 'MockIpfs');
  }

  @override
  Future<String?> getCommunityIcon(String? cid) {
    return Future.value(mockIcon);
  }

  @override
  Future<String> uploadImage(File image) async {
    Log.d('unimplemented uploadImage', 'MockIpfs');
    return 'unimplemented uploadImage';
  }

  @override
  Future<String> uploadJson(Map<String, dynamic> json) async {
    Log.d('unimplemented uploadJson', 'MockIpfs');
    return 'unimplemented uploadJson';
  }
}
