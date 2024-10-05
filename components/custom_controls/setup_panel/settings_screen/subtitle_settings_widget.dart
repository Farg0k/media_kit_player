import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../const/player_const.dart';
import '../../../../../entity/player_settings.dart';
import '../../../../bloc/media_kit_player_bloc.dart';
import '../../../../media_kit_player_screen.dart';
import 'color_selector_widget.dart';

class SubtitleSettingsWidget extends StatelessWidget {
  final VideoState videoState;
  final MediaKitPlayerBloc bloc;
  const SubtitleSettingsWidget({super.key, required this.videoState, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (canPop, result) async {
        if (bloc.state.isChangePlayerSettings == true) {
          //await _setSettings();
        } else {
          bloc.add(const SetActivePanel(playerPanel: PlayerPanel.setup));
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListTile(
            leading: const Icon(Icons.subtitles_outlined),
            title: Text(S.of(context).subtitleSettings),
            titleTextStyle: Theme.of(context).textTheme.headlineMedium,
          ),
          CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.arrowLeft): () => Navigator.of(context).pop(),
              const SingleActivator(LogicalKeyboardKey.arrowRight): () => Navigator.of(context).pop(),
              const SingleActivator(LogicalKeyboardKey.contextMenu): () => Navigator.of(context).pop(),
              const SingleActivator(LogicalKeyboardKey.keyQ): () => Navigator.of(context).pop(),
            },
            child: BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
              bloc: bloc,
              buildWhen: (oldState, newState) => oldState.playerSettings != newState.playerSettings,
              builder: (context, state) {
                return ListView(
                  shrinkWrap: true,
                  children: [
                    ListTile(
                      title: Text(S.of(context).fontColor),
                      subtitle: ColorSelectorWidget(
                        initialItem: bloc.state.playerSettings.subtitleFontColor,
                        saveResult: (int itemIndex) async {
                          final playerSettings = bloc.state.playerSettings.copyWith(subtitleFontColor: itemIndex);
                          bloc.add(SetPlayerSettings(playerSettings: playerSettings, isChangePlayerSettings: true));
                          await _setSettings(playerSettings: playerSettings);
                        },
                        autofocus: true,
                      ),
                      titleTextStyle: Theme.of(context).textTheme.titleLarge,
                    ),
                    ListTile(
                      title: Text(S.of(context).backgroundColor),
                      subtitle: ColorSelectorWidget(
                        initialItem: bloc.state.playerSettings.subtitleBackgroundColor,
                        saveResult: (int itemIndex) async {
                          final playerSettings = bloc.state.playerSettings.copyWith(subtitleBackgroundColor: itemIndex);
                          bloc.add(SetPlayerSettings(playerSettings: playerSettings, isChangePlayerSettings: true));
                          await _setSettings(playerSettings: playerSettings);
                        },
                      ),
                      titleTextStyle: Theme.of(context).textTheme.titleLarge,
                    ),
                    Material(
                      child: CallbackShortcuts(
                        bindings: {
                          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _setFontSize(action: -1),
                          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _setFontSize(action: 1),
                        },
                        child: ListTile(
                          onTap: () => _setFontSize(action: 1),
                          title: Text(S.of(context).fontSize),
                          focusColor: AppTheme.seedColor,
                          subtitle: Row(
                            children: [
                              const Icon(Icons.arrow_left, color: Colors.blue),
                              Text(
                                '${bloc.state.playerSettings.subtitleFontSize} px',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Icon(Icons.arrow_right, color: Colors.blue),
                            ],
                          ),
                          titleTextStyle: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    Material(
                      child: CallbackShortcuts(
                        bindings: {
                          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _setPadding(
                                action: -1,
                                subtitlePadding: bloc.state.playerSettings.subtitleLeftPadding,
                                side: 'left',
                              ),
                          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _setPadding(
                                action: 1,
                                subtitlePadding: bloc.state.playerSettings.subtitleLeftPadding,
                                side: 'left',
                              ),
                        },
                        child: ListTile(
                          onTap: () => _setPadding(
                            action: 1,
                            subtitlePadding: bloc.state.playerSettings.subtitleLeftPadding,
                            side: 'left',
                          ),
                          title: Text(S.of(context).leftPadding),
                          focusColor: AppTheme.seedColor,
                          subtitle: Row(
                            children: [
                              const Icon(Icons.arrow_left, color: Colors.blue),
                              Text(
                                '${bloc.state.playerSettings.subtitleLeftPadding} px',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Icon(Icons.arrow_right, color: Colors.blue),
                            ],
                          ),
                          titleTextStyle: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    Material(
                      child: CallbackShortcuts(
                        bindings: {
                          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _setPadding(
                                action: -1,
                                subtitlePadding: bloc.state.playerSettings.subtitleRightPadding,
                                side: 'right',
                              ),
                          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _setPadding(
                                action: 1,
                                subtitlePadding: bloc.state.playerSettings.subtitleRightPadding,
                                side: 'right',
                              ),
                        },
                        child: ListTile(
                          onTap: () => _setPadding(
                            action: 1,
                            subtitlePadding: bloc.state.playerSettings.subtitleRightPadding,
                            side: 'right',
                          ),
                          title: Text(S.of(context).rightPadding),
                          focusColor: AppTheme.seedColor,
                          subtitle: Row(
                            children: [
                              const Icon(Icons.arrow_left, color: Colors.blue),
                              Text(
                                '${bloc.state.playerSettings.subtitleRightPadding} px',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Icon(Icons.arrow_right, color: Colors.blue),
                            ],
                          ),
                          titleTextStyle: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    Material(
                      child: CallbackShortcuts(
                        bindings: {
                          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _setPadding(
                                action: -1,
                                subtitlePadding: bloc.state.playerSettings.subtitleBottomPadding,
                                side: 'bottom',
                              ),
                          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _setPadding(
                                action: 1,
                                subtitlePadding: bloc.state.playerSettings.subtitleBottomPadding,
                                side: 'bottom',
                              ),
                        },
                        child: ListTile(
                          onTap: () => _setPadding(
                            action: 1,
                            subtitlePadding: bloc.state.playerSettings.subtitleBottomPadding,
                            side: 'bottom',
                          ),
                          title: Text(S.of(context).bottomPadding),
                          focusColor: AppTheme.seedColor,
                          subtitle: Row(
                            children: [
                              const Icon(Icons.arrow_left, color: Colors.blue),
                              Text(
                                '${bloc.state.playerSettings.subtitleBottomPadding} px',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const Icon(Icons.arrow_right, color: Colors.blue),
                            ],
                          ),
                          titleTextStyle: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _setSettings({required PlayerSettings playerSettings}) async {
    //todo check
    keyGlobalMKPlayer.currentState?.update(
      subtitleViewConfiguration: SubtitleViewConfiguration(
        style: TextStyle(
          fontSize: playerSettings.subtitleFontSize,
          color: PlayerConst.colorList[playerSettings.subtitleFontColor],
          backgroundColor: PlayerConst.colorList[playerSettings.subtitleBackgroundColor],
        ),
        textAlign: TextAlign.start,
        padding: EdgeInsets.fromLTRB(
          playerSettings.subtitleLeftPadding,
          5,
          playerSettings.subtitleRightPadding,
          playerSettings.subtitleBottomPadding,
        ),
      ),
    );
  }

  Future<void> _setFontSize({required double action}) async {
    final fontSize = bloc.state.playerSettings.subtitleFontSize + action > 150
        ? 14.0
        : bloc.state.playerSettings.subtitleFontSize + action < 14
            ? 150.0
            : bloc.state.playerSettings.subtitleFontSize + action;
    final playerSettings = bloc.state.playerSettings.copyWith(subtitleFontSize: fontSize);
    bloc.add(SetPlayerSettings(playerSettings: playerSettings, isChangePlayerSettings: true));
    await _setSettings(playerSettings: playerSettings);
  }

  Future<void> _setPadding({
    required double action,
    required double subtitlePadding,
    required String side,
  }) async {
    action = subtitlePadding + action;

    final leftPadding = side == 'left'
        ? action > 100
            ? 0.0
            : action < 0
                ? 100.0
                : action
        : null;
    final rightPadding = side == 'right'
        ? action > 100
            ? 0.0
            : action < 0
                ? 100.0
                : action
        : null;
    final bottomPadding = side == 'bottom'
        ? action > 200
            ? 0.0
            : action < 0
                ? 200.0
                : action
        : null;
    final playerSettings = bloc.state.playerSettings.copyWith(
      subtitleLeftPadding: leftPadding,
      subtitleRightPadding: rightPadding,
      subtitleBottomPadding: bottomPadding,
    );
    bloc.add(SetPlayerSettings(playerSettings: playerSettings, isChangePlayerSettings: true));
    await _setSettings(playerSettings: playerSettings);
  }
}
