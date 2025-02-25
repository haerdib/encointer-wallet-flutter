import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:encointer_wallet/gen/assets.gen.dart';
import 'package:encointer_wallet/common/components/secondary_button_wide.dart';
import 'package:encointer_wallet/common/components/logo/encointer_logo.dart';
import 'package:encointer_wallet/modules/modules.dart';
import 'package:encointer_wallet/utils/translations/index.dart';

class CreateAccountEntryView extends StatelessWidget {
  const CreateAccountEntryView({super.key});

  static const String route = '/account/entry';

  @override
  Widget build(BuildContext context) {
    final dic = I18n.of(context)!.translationsForLocale();
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(image: Assets.images.assets.mosaicBackground.provider(), fit: BoxFit.cover),
        ),
        child: Column(
          children: <Widget>[
            const Spacer(),
            const EncointerLogo(),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SecondaryButtonWide(
                key: const Key('create-account'),
                onPressed: () => Navigator.pushNamed(context, CreateAccountView.route),
                child: Text(dic.home.create, style: textTheme.displaySmall),
              ),
            ),
            const SizedBox(height: 16),
            ImportAccountLink(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext _) => Provider(
                      create: (_) => NewAccountStore(),
                      child: const ImportAccountView(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
