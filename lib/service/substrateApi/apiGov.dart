import 'package:polka_wallet/store/app.dart';
import 'package:polka_wallet/service/substrateApi/api.dart';

class ApiGovernance {
  ApiGovernance(this.apiRoot);

  final Api apiRoot;
  final store = globalAppStore;

  Future<Map> fetchCouncilInfo() async {
    Map info = await apiRoot.evalJavascript('api.derive.elections.info()');
    if (info != null) {
      List all = [];
      all.addAll(info['members'].map((i) => i[0]));
      all.addAll(info['runnersUp'].map((i) => i[0]));
      all.addAll(info['candidates']);
      store.gov.setCouncilInfo(info);
      apiRoot.account.fetchAccountsIndex(all);
      apiRoot.account.getAddressIcons(all);
    }
    return info;
  }

  Future<Map> fetchReferendums() async {
    Map data = await apiRoot.evalJavascript('gov.fetchReferendums()');
    if (data != null) {
      List list = data['referendums'];
      if (list.length > 0) {
        list.asMap().forEach((k, v) {
          v['detail'] = data['details'][k];
        });
        store.gov.setReferendums(List<Map<String, dynamic>>.from(list));
      }
    }
    return data;
  }
}
