import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/injector/injector.dart';
import 'package:piwigo_ng/core/presentation/widgets/buttons/custom_text_button.dart';
import 'package:piwigo_ng/core/router/app_routes.dart';
import 'package:piwigo_ng/core/utils/app_assets.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/login/login_bloc.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/session_status/session_status_bloc.dart';
import 'package:piwigo_ng/features/authentication/presentation/widgets/login_form_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String get appVersion => serviceLocator<PackageInfo>().version;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (_) => LoginBloc(),
      child: BlocListener<SessionStatusBloc, SessionStatusState>(
        listener: (BuildContext context, SessionStatusState state) => state.whenOrNull<void>(
          failure: (Failure failure) => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.getMessage(context)),
            ),
          ),
          loggedIn: (_) => context.navigator.pushReplacementNamed(AppRoutes.root),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: context.screenSize(safeArea: true).height,
                child: Column(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.paddingLarge,
                              vertical: UIConstants.paddingXSmall,
                            ),
                            child: Image.asset(
                              AppAssets.piwigoLogo,
                              fit: BoxFit.scaleDown,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {}, // todo: login settings
                              icon: const Icon(Icons.settings),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const LoginFormView(),
                    Expanded(
                      flex: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          CustomTextButton(
                            onTap: () {}, // todo: show privacy policy
                            text: context.localizations.settings_privacy,
                          ),
                          Text(appVersion),
                          const SizedBox(height: UIConstants.paddingXSmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
