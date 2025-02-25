import 'package:flutter/material.dart';

import 'package:encointer_wallet/common/theme.dart';
import 'package:encointer_wallet/utils/translations/index.dart';

class ImportAccountLink extends StatelessWidget {
  const ImportAccountLink({super.key, this.onTap});

  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.translationsForLocale();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${dic.profile.doYouAlreadyHaveAnAccount} ',
          style: TextStyle(color: zurichLion.shade50),
        ),
        InkWell(
          key: const Key('import-account'),
          onTap: onTap,
          child: Text(
            dic.profile.import,
            style: TextStyle(color: zurichLion.shade50, decoration: TextDecoration.underline),
          ),
        ),
      ],
    );
  }
}
