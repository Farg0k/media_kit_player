
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../bloc/media_kit_player_bloc.dart';
import 'color_selector_widget.dart';

class ClockSettings extends StatelessWidget {
  final VideoState videoState;
  final MediaKitPlayerBloc bloc;
  const ClockSettings({super.key, required this.videoState, required this.bloc});

  void _returnToMenu({required BuildContext context}) {
    Navigator.pop(context);
    bloc.add(const SetActivePanel(playerPanel: PlayerPanel.setup));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
      bloc: bloc,
      buildWhen: (oldState, newState) => oldState.playerSettings != newState.playerSettings,
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ListTile(
              leading: const Icon(Icons.access_time),
              title: Text(S.of(context).clock),
              titleTextStyle: Theme.of(context).textTheme.headlineMedium,
            ),
            CallbackShortcuts(
              bindings: {
                const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _returnToMenu(context: context),
                const SingleActivator(LogicalKeyboardKey.arrowRight): () => _returnToMenu(context: context),
                const SingleActivator(LogicalKeyboardKey.contextMenu): () => _returnToMenu(context: context),
                const SingleActivator(LogicalKeyboardKey.keyQ): () => _returnToMenu(context: context),
              },
              child: ListView(
                shrinkWrap: true,
                children: [
                  Material(
                    child: ListTile(
                      title: Text(S.of(context).position),
                      titleTextStyle: Theme.of(context).textTheme.titleLarge,
                      subtitle: Text(ClockPosition.values[state.playerSettings.clockPosition].title),
                      focusColor: AppTheme.seedColor,
                      autofocus: true,
                      onTap: () {
                        final i = state.playerSettings.clockPosition + 1;
                        final clockPosition = i > ClockPosition.values.length - 1 ? 0 : i;
                        bloc.add(SetPlayerSettings(
                            playerSettings: state.playerSettings.copyWith(clockPosition: clockPosition)));
                      },
                    ),
                  ),
                  Material(
                    child: ListTile(
                      title: Text(S.of(context).showBorder),
                      titleTextStyle: Theme.of(context).textTheme.titleLarge,
                      subtitle: Text(state.playerSettings.showClockBorder ? S.of(context).yes : S.of(context).no),
                      focusColor: AppTheme.seedColor,
                      onTap: () {
                        bloc.add(SetPlayerSettings(
                            playerSettings: state.playerSettings
                                .copyWith(showClockBorder: !state.playerSettings.showClockBorder)));
                      },
                      trailing: Switch(value: state.playerSettings.showClockBorder, onChanged: (val) {}),
                    ),
                  ),
                  Material(
                    child: ListTile(
                      title: Text(S.of(context).showBackground),
                      titleTextStyle: Theme.of(context).textTheme.titleLarge,
                      subtitle:
                          Text(state.playerSettings.showClockBackground ? S.of(context).yes : S.of(context).no),
                      focusColor: AppTheme.seedColor,
                      onTap: () {
                        bloc.add(
                          SetPlayerSettings(
                            playerSettings: state.playerSettings
                                .copyWith(showClockBackground: !state.playerSettings.showClockBackground),
                          ),
                        );
                      },
                      trailing: Switch(value: state.playerSettings.showClockBackground, onChanged: (val) {}),
                    ),
                  ),
                  ListTile(
                    title: Text(S.of(context).color),
                    subtitle: ColorSelectorWidget(
                      initialItem: state.playerSettings.clockColor,
                      saveResult: (int itemIndex) => bloc.add(
                        SetPlayerSettings(
                          playerSettings: state.playerSettings.copyWith(clockColor: itemIndex),
                        ),
                      ),
                    ),
                    titleTextStyle: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
