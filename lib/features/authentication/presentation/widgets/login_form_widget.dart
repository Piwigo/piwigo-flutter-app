import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/presentation/widgets/animated/collapsible_widget.dart';
import 'package:piwigo_ng/core/presentation/widgets/buttons/custom_button.dart';
import 'package:piwigo_ng/core/presentation/widgets/form/custom_text_field.dart';
import 'package:piwigo_ng/core/utils/app_strings.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';
import 'package:piwigo_ng/core/utils/validators/field_validator.dart';
import 'package:piwigo_ng/features/authentication/domain/usecases/login_use_case.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/login/login_bloc.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/session_status/session_status_bloc.dart';

class LoginFormView extends StatefulWidget {
  const LoginFormView({
    super.key,
    this.autoLogin = false,
  });

  final bool autoLogin;

  @override
  State<LoginFormView> createState() => _LoginFormViewState();
}

class _LoginFormViewState extends State<LoginFormView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  UrlSchemeEnum _scheme = UrlSchemeEnum.https;
  bool _showPassword = false;
  bool _isGuest = false;

  @override
  void dispose() {
    _urlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isSecured => _scheme == UrlSchemeEnum.https;

  void _onLogin() {
    if (!(_formKey.currentState?.validate() == true)) return;

    // Build uri from scheme and authority
    late Uri url;
    if (_scheme == UrlSchemeEnum.http) {
      url = Uri.http(_urlController.text);
    } else {
      url = Uri.https(_urlController.text);
    }

    if (_isGuest) {
      BlocProvider.of<LoginBloc>(context).add(
        LoginEvent.loginGuest(url: url),
      );
    } else {
      BlocProvider.of<LoginBloc>(context).add(
        LoginEvent.loginUser(
          url: url,
          username: _usernameController.text,
          password: _passwordController.text,
        ),
      );
    }
  }

  void _switchProtocol() {
    setState(() {
      if (_scheme == UrlSchemeEnum.https) {
        _scheme = UrlSchemeEnum.http;
      } else {
        _scheme = UrlSchemeEnum.https;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: DefaultTabController(
        length: 2,
        child: Form(
          key: _formKey,
          child: BlocBuilder<SessionStatusBloc, SessionStatusState>(
            builder: (BuildContext context, SessionStatusState sessionStatusState) =>
                BlocConsumer<LoginBloc, LoginState>(
              listener: (BuildContext context, LoginState loginState) => loginState.whenOrNull(
                failure: (Failure failure) => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(failure.getMessage(context)),
                  ),
                ),
                success: () => BlocProvider.of<SessionStatusBloc>(context).add(const SessionStatusEvent.getStatus()),
              ),
              builder: (BuildContext context, LoginState state) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Container(
                        decoration: ShapeDecoration(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
                          ),
                          color: context.theme.inputDecorationTheme.fillColor,
                        ),
                        child: TabBar(
                          indicator: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
                            ),
                            color: context.theme.colorScheme.secondary,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          tabs: const <Widget>[
                            Tab(text: 'User'), // todo: localization
                            Tab(text: 'Guest'), // todo: localization
                          ],
                          onTap: (int index) => setState(() => _isGuest = index == 1),
                        ),
                      ),
                      const SizedBox(height: UIConstants.paddingMedium),
                      CustomTextField(
                        padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.paddingMedium,
                          horizontal: UIConstants.paddingXSmall,
                        ).copyWith(left: 0.0),
                        controller: _urlController,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.url],
                        prefix: _securedPrefix,
                        hint: AppStrings.piwigoUrlSample,
                        validators: <FieldValidator>[
                          RequiredValidator(),
                          UrlValidator(),
                        ],
                      ),
                      CollapsibleWidget(
                        expanded: !_isGuest,
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: UIConstants.paddingXSmall),
                            CustomTextField(
                              controller: _usernameController,
                              textInputAction: TextInputAction.next,
                              autofillHints: const <String>[AutofillHints.username],
                              hint: context.localizations.loginHTTPuser_placeholder,
                              prefix: const Icon(Icons.person),
                              canErase: true,
                              validators: <FieldValidator>[
                                if (!_isGuest) RequiredValidator(),
                              ],
                            ),
                            const SizedBox(height: UIConstants.paddingXSmall),
                            CustomTextField(
                              controller: _passwordController,
                              textInputAction: TextInputAction.done,
                              autofillHints: const <String>[AutofillHints.password],
                              obscureText: !_showPassword,
                              hint: context.localizations.loginHTTPpwd_placeholder,
                              prefix: GestureDetector(
                                onTap: () => setState(() {
                                  _showPassword = !_showPassword;
                                }),
                                child: Icon(_showPassword ? Icons.lock_open : Icons.lock),
                              ),
                              canErase: true,
                              onFieldSubmitted: (String value) {
                                FocusScope.of(context).unfocus();
                                _onLogin();
                              },
                              validators: <FieldValidator>[
                                if (!_isGuest) RequiredValidator(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: UIConstants.paddingMedium),
                      CustomButton(
                        onTap: _onLogin,
                        text: context.localizations.login,
                        isLoading: state.isLoading || sessionStatusState.isLoading,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget get _securedPrefix {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _switchProtocol,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.public),
          const SizedBox(width: UIConstants.paddingXSmall),
          Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Text(
                '${_isSecured ? AppStrings.https : AppStrings.http}${AppStrings.hostSeparator}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Positioned(
                top: Theme.of(context).textTheme.bodyMedium?.fontSize,
                child: Text(
                  !_isSecured ? AppStrings.https : AppStrings.http,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
