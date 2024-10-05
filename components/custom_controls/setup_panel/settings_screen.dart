import '../../../../utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../generated/l10n.dart';
import '../../../../const/player_const.dart';
import '../../../bloc/media_kit_player_bloc.dart';

import '../../side_sheet_widget.dart';
import 'settings_screen/clock_settings.dart';
import 'settings_screen/sleep_timer_widget.dart';
import 'settings_screen/speed_panel_widget.dart';
import 'settings_screen/subtitle_settings_widget.dart';
import 'settings_screen/zoom_panel_widget.dart';

class SettingsScreen extends StatelessWidget {
  final VideoState videoState;
  const SettingsScreen({super.key, required this.videoState});

  @override
  Widget build(BuildContext context) {
    final settingsItemIndex = context.read<MediaKitPlayerBloc>().state.settingsItemIndex;
    return ListView(
      children: [
        Material(
          child: CallbackShortcuts(
            bindings: {const SingleActivator(LogicalKeyboardKey.arrowUp): () {}},
            child: ListTile(
              autofocus: settingsItemIndex == 0,
              focusColor: Theme.of(context).focusColor,
              onFocusChange: (focus) {
                if (focus == true) {
                  context.read<MediaKitPlayerBloc>().add(const SetSettingsItemIndex(index: 0));
                }
              },
              leading: const Icon(Icons.timelapse),
              title: Text(S.of(context).sleepTimer),
              trailing: BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
                buildWhen: (oldState, newState) =>
                    oldState.sleepTime != newState.sleepTime || oldState.sleepAfter != newState.sleepAfter,
                builder: (context, state) {
                  if (state.sleepTime != Duration.zero) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Icon(Icons.access_time_filled_outlined, color: Colors.grey),
                        const SizedBox(width: 5),
                        Text(state.sleepTime.toString().durationClear()),
                      ],
                    );
                  }
                  if (state.sleepAfter != false) {
                    return Text(S.of(context).afterThisFile);
                  }
                  return Text(S.of(context).off);
                },
              ),
              onTap: () {
                context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
                SideSheetWidget.openSideSheet(
                  context: context,
                  body: SleepTimerWidget(bloc: context.read<MediaKitPlayerBloc>()),
                );
              },
              titleTextStyle: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
        ),
        Material(
          child: ListTile(
            autofocus: settingsItemIndex == 1,
            focusColor: Theme.of(context).focusColor,
            onFocusChange: (focus) {
              if (focus == true) {
                context.read<MediaKitPlayerBloc>().add(const SetSettingsItemIndex(index: 1));
              }
            },
            leading: const Icon(Icons.zoom_in),
            title: Text(S.of(context).zoom),
            trailing: Text(PlayerConst.zoom[videoState.widget.fit] ?? ''),
            onTap: () {
              context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
              SideSheetWidget.openSideSheet(
                context: context,
                body: ZoomPanelWidget(
                  videoState: videoState,
                  bloc: context.read<MediaKitPlayerBloc>(),
                ),
              );
            },
            titleTextStyle: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Material(
          child: ListTile(
            focusColor: Theme.of(context).focusColor,
            autofocus: settingsItemIndex == 2,
            onFocusChange: (focus) {
              if (focus == true) {
                context.read<MediaKitPlayerBloc>().add(const SetSettingsItemIndex(index: 2));
              }
            },
            leading: const Icon(Icons.speed),
            title: Text(S.of(context).speed),
            trailing: Text('${videoState.widget.controller.player.state.rate}x'),
            onTap: () {
              context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
              SideSheetWidget.openSideSheet(
                context: context,
                body: SpeedPanelWidget(
                  videoState: videoState,
                  bloc: context.read<MediaKitPlayerBloc>(),
                ),
              );
            },
            titleTextStyle: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Material(
          child: BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
            buildWhen: (oldState, newState) => oldState.repeat != newState.repeat,
            builder: (context, state) {
              return ListTile(
                focusColor: Theme.of(context).focusColor,
                autofocus: settingsItemIndex == 3,
                onFocusChange: (focus) {
                  if (focus == true) {
                    context.read<MediaKitPlayerBloc>().add(const SetSettingsItemIndex(index: 3));
                  }
                },
                leading: state.repeat == Repeat.none
                    ? const Icon(Icons.repeat_on)
                    : state.repeat == Repeat.one
                        ? const Icon(Icons.repeat_one)
                        : const Icon(Icons.repeat),
                title: Text(S.of(context).repeat),
                trailing: Text(state.repeat.name),
                onTap: () {
                  final repeat = state.repeat == Repeat.none
                      ? Repeat.one
                      : state.repeat == Repeat.one
                          ? Repeat.all
                          : Repeat.none;
                  context.read<MediaKitPlayerBloc>().add(SetRepeat(repeat: repeat));
                },
                titleTextStyle: Theme.of(context).textTheme.headlineSmall,
              );
            },
          ),
        ),
        Material(
          child: BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
            buildWhen: (oldState, newState) => oldState.randomPlay != newState.randomPlay,
            builder: (context, state) {
              return ListTile(
                focusColor: Theme.of(context).focusColor,
                autofocus: settingsItemIndex == 4,
                onFocusChange: (focus) {
                  if (focus == true) {
                    context.read<MediaKitPlayerBloc>().add(const SetSettingsItemIndex(index: 4));
                  }
                },
                leading: state.randomPlay == false ? const Icon(Icons.list) : const Icon(Icons.shuffle),
                title: Text(S.of(context).random),
                trailing: Text(state.randomPlay == true ? S.of(context).on : S.of(context).off),
                onTap: () => context.read<MediaKitPlayerBloc>().add(SetRandomWatch(value: !state.randomPlay)),
                titleTextStyle: Theme.of(context).textTheme.headlineSmall,
              );
            },
          ),
        ),
        Material(
          child: ListTile(
            focusColor: Theme.of(context).focusColor,
            autofocus: settingsItemIndex == 5,
            leading: const Icon(Icons.subtitles_outlined),
            title: Text(S.of(context).subtitleSettings),
            onFocusChange: (focus) {
              if (focus == true) {
                context.read<MediaKitPlayerBloc>().add(const SetSettingsItemIndex(index: 5));
              }
            },
            onTap: () {
              context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
              SideSheetWidget.openSideSheet(
                context: context,
                body: SubtitleSettingsWidget(
                  videoState: videoState,
                  bloc: context.read<MediaKitPlayerBloc>(),
                ),
              );
            },
            titleTextStyle: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Material(
          child: ListTile(
            focusColor: Theme.of(context).focusColor,
            autofocus: settingsItemIndex == 6,
            onFocusChange: (focus) {
              if (focus == true) {
                context.read<MediaKitPlayerBloc>().add(const SetSettingsItemIndex(index: 6));
              }
            },
            leading: const Icon(Icons.access_time),
            title: Text(S.of(context).clock),
            onTap: () {
              context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
              SideSheetWidget.openSideSheet(
                context: context,
                body: ClockSettings(
                  videoState: videoState,
                  bloc: context.read<MediaKitPlayerBloc>(),
                ),
              );
            },
            titleTextStyle: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ],
    );
  }
}
