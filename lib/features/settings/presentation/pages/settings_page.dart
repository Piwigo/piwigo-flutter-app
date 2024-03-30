import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piwigo_ng/core/extensions/build_context_extension.dart';
import 'package:piwigo_ng/core/presentation/widgets/buttons/custom_button.dart';
import 'package:piwigo_ng/core/utils/constants/ui_constants.dart';
import 'package:piwigo_ng/features/authentication/data/enums/user_status_enum.dart';
import 'package:piwigo_ng/features/authentication/presentation/blocs/session_status/session_status_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void _onLogout(BuildContext context) =>
      BlocProvider.of<SessionStatusBloc>(context).add(const SessionStatusEvent.logout());

  @override
  Widget build(BuildContext context) => BlocBuilder<SessionStatusBloc, SessionStatusState>(
        builder: (BuildContext context, SessionStatusState sessionState) => Scaffold(
          body: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                title: Text(context.localizations.tabBar_preferences),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.paddingMedium,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CustomButton(
                        onTap: () => _onLogout(context),
                        isLoading: sessionState.isLoading,
                        text: sessionState.userStatus.isGuest
                            ? context.localizations.login
                            : context.localizations.settings_logout,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
