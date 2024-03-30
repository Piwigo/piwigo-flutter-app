import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piwigo_ng/core/errors/failures.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/router/app_routes.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/login/login_bloc.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/session_status/session_status_bloc.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  @override
  Widget build(BuildContext context) => BlocProvider<LoginBloc>(
        create: (BuildContext context) => LoginBloc()..add(const LoginEvent.autoLogin()),
        child: MultiBlocListener(
          listeners: <BlocListener<dynamic, dynamic>>[
            BlocListener<LoginBloc, LoginState>(
              listener: (BuildContext context, LoginState state) => state.whenOrNull(
                failure: (Failure failure) => context.navigator.pushReplacementNamed(AppRoutes.login),
                success: () => BlocProvider.of<SessionStatusBloc>(context).add(const SessionStatusEvent.getStatus()),
              ),
            ),
            BlocListener<SessionStatusBloc, SessionStatusState>(
              listener: (BuildContext context, SessionStatusState state) => state.whenOrNull(
                failure: (Failure failure) => context.navigator.pushReplacementNamed(AppRoutes.login),
                loggedIn: (_) => context.navigator.pushReplacementNamed(AppRoutes.root),
              ),
            ),
          ],
          child: const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
}
