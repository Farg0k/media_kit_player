import '../components/placeholder_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../bloc/media_kit_player_bloc.dart';
import 'custom_controls/clock_panel.dart';
import 'custom_controls/info_panel.dart';
import 'custom_controls/setup_panel.dart';
import 'custom_controls/simple_panel.dart';

class MediaKitCustomControls extends StatefulWidget {
  final VideoState videoState;
  final Function(int, String, int?, int?) saveWatchTime;
  const MediaKitCustomControls({super.key, required this.videoState, required this.saveWatchTime});

  @override
  State<MediaKitCustomControls> createState() => _MediaKitCustomControlsState();
}

class _MediaKitCustomControlsState extends State<MediaKitCustomControls> {
  bool rewindLock = false;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
      buildWhen: (oldState, newState) => oldState.playerPanel != newState.playerPanel,
      builder: (context, state) {
        if (state.playerPanel == PlayerPanel.buffering) {
          return PlaceholderWidget(
            placeholderImg: state.playItems[state.playIndex].placeholderImg,
            text: 'Loading...',
          );
        }
        if (state.playerPanel == PlayerPanel.info) {
          return CallbackShortcuts(
            bindings: _generalBindings(context: context, state: state),
            child: InfoPanel(videoState: widget.videoState),
          );
        }
        if (state.playerPanel == PlayerPanel.setup) {
          return SetupPanel(
            videoState: widget.videoState,
            selSettingsTab: state.tabIndex,
            saveWatchTime: widget.saveWatchTime,
          );
        }
        if (state.playerPanel == PlayerPanel.simple) {
          return CallbackShortcuts(
            bindings: _simpleBindings(context: context, state: state),
            child: SimplePanel(videoState: widget.videoState),
          );
        }
        return CallbackShortcuts(
          bindings: _generalBindings(context: context, state: state),
          child: Focus(
            autofocus: true,
            child: Stack(
              children: [
                ClockPanel(
                  videoState: widget.videoState,
                ),
                widget.videoState.widget.controller.player.state.playing == false &&
                        widget.videoState.widget.controller.player.state.buffering == false
                    ? const Center(
                        child: Icon(
                          Icons.pause,
                          color: Colors.white,
                          size: 140,
                          shadows: [
                            Shadow(color: Colors.black, offset: Offset(2, 2)),
                            Shadow(color: Colors.black, offset: Offset(-2, -2)),
                            Shadow(color: Colors.black, offset: Offset(-2, 2)),
                            Shadow(color: Colors.black, offset: Offset(2, -2)),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }

  Map<ShortcutActivator, VoidCallback> _generalBindings(
      {required BuildContext context, required MediaKitPlayerState state}) {
    return {
      //stop
      const SingleActivator(LogicalKeyboardKey.mediaStop): () {
        _openPanel(context: context, state: state, playerPanel: PlayerPanel.none);
        _saveWatchTime();
        Navigator.pop(context);
      },
      const SingleActivator(LogicalKeyboardKey.keyE): () {
        _openPanel(context: context, state: state, playerPanel: PlayerPanel.none);
        _saveWatchTime();
        Navigator.pop(context);
      },
      //menu
      const SingleActivator(LogicalKeyboardKey.contextMenu): () =>
          _openPanel(context: context, state: state, playerPanel: PlayerPanel.setup),
      const SingleActivator(LogicalKeyboardKey.keyQ): () =>
          _openPanel(context: context, state: state, playerPanel: PlayerPanel.setup),
      // //info
      const SingleActivator(LogicalKeyboardKey.info): () =>
          _openPanel(context: context, state: state, playerPanel: PlayerPanel.info),
      const SingleActivator(LogicalKeyboardKey.keyW): () =>
          _openPanel(context: context, state: state, playerPanel: PlayerPanel.info),
      //play/pause
      const SingleActivator(LogicalKeyboardKey.enter): () => _playPause(context: context),
      const SingleActivator(LogicalKeyboardKey.space): () => _playPause(context: context),
      const SingleActivator(LogicalKeyboardKey.select): () => _playPause(context: context),
      const SingleActivator(LogicalKeyboardKey.mediaPlayPause): () => _playPause(context: context),
      // go to prsnt
      const SingleActivator(LogicalKeyboardKey.digit0): () => _goToVideoPercentage(percentage: 0, context: context),
      const SingleActivator(LogicalKeyboardKey.digit1): () => _goToVideoPercentage(percentage: 0.1, context: context),
      const SingleActivator(LogicalKeyboardKey.digit2): () => _goToVideoPercentage(percentage: 0.2, context: context),
      const SingleActivator(LogicalKeyboardKey.digit3): () => _goToVideoPercentage(percentage: 0.3, context: context),
      const SingleActivator(LogicalKeyboardKey.digit4): () => _goToVideoPercentage(percentage: 0.4, context: context),
      const SingleActivator(LogicalKeyboardKey.digit5): () => _goToVideoPercentage(percentage: 0.5, context: context),
      const SingleActivator(LogicalKeyboardKey.digit6): () => _goToVideoPercentage(percentage: 0.6, context: context),
      const SingleActivator(LogicalKeyboardKey.digit7): () => _goToVideoPercentage(percentage: 0.7, context: context),
      const SingleActivator(LogicalKeyboardKey.digit8): () => _goToVideoPercentage(percentage: 0.8, context: context),
      const SingleActivator(LogicalKeyboardKey.digit9): () => _goToVideoPercentage(percentage: 0.9, context: context),
      //next & prew files
      const SingleActivator(LogicalKeyboardKey.arrowUp): () => _arrowFunction(context: context, action: 1),
      const SingleActivator(LogicalKeyboardKey.arrowDown): () => _arrowFunction(context: context, action: -1),
      //next & prew files
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _arrowRewind(context: context, action: -60),
      const SingleActivator(LogicalKeyboardKey.arrowRight): () => _arrowRewind(context: context, action: 60),
      const SingleActivator(LogicalKeyboardKey.pageUp): () => _arrowRewind(context: context, action: 600),
      const SingleActivator(LogicalKeyboardKey.pageDown): () => _arrowRewind(context: context, action: -600),
    };
  }

  Map<ShortcutActivator, VoidCallback> _simpleBindings(
      {required BuildContext context, required MediaKitPlayerState state}) {
    Map<ShortcutActivator, VoidCallback> map = _generalBindings(context: context, state: state);
    map[const SingleActivator(LogicalKeyboardKey.arrowUp)] = () => _arrowRewind(context: context, action: 600);
    map[const SingleActivator(LogicalKeyboardKey.arrowDown)] = () => _arrowRewind(context: context, action: -600);
    return map;
  }

  void _openPanel(
      {required BuildContext context, required MediaKitPlayerState state, required PlayerPanel playerPanel}) {
    if (state.sideSheetOpen == true) {
      Navigator.of(context).pop();
    }
    context
        .read<MediaKitPlayerBloc>()
        .add(SetActivePanel(playerPanel: state.playerPanel == playerPanel ? PlayerPanel.none : playerPanel));
  }

  Future<void> _playPause({required BuildContext context}) async {
    final bloc = context.read<MediaKitPlayerBloc>();
    await widget.videoState.widget.controller.player.playOrPause();
    bool enable = widget.videoState.widget.controller.player.state.playing;
    WakelockPlus.toggle(enable: enable);
    bloc.add(const SetActivePanel(playerPanel: PlayerPanel.info, debounce: true));
  }

  Future<void> _goToVideoPercentage({required BuildContext context, required double percentage}) async {
    final duration = widget.videoState.widget.controller.player.state.duration.inSeconds.toInt();
    if (duration > 0) {
      final bloc = context.read<MediaKitPlayerBloc>();
      final seconds = (duration.toDouble() * percentage).toInt();
      await widget.videoState.widget.controller.player.seek(Duration(seconds: seconds));
      bloc.add(const SetActivePanel(playerPanel: PlayerPanel.info, debounce: true));
    }
  }

  Future<void> _arrowRewind({required BuildContext context, required int action}) async {
    if (rewindLock == false) {
      rewindLock = true;
      context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.simple, debounce: true));
      final position = widget.videoState.widget.controller.player.state.position.inSeconds.toInt();
      final duration = widget.videoState.widget.controller.player.state.duration.inSeconds.toInt();
      final seconds = position + action < 0
          ? 0
          : position + action > duration
              ? duration - 5
              : position + action;
      await widget.videoState.widget.controller.player.seek(Duration(seconds: seconds));
      rewindLock = false;
    }
  }

  _arrowFunction({required BuildContext context, required int action}) {
    _saveWatchTime();
    final bloc = context.read<MediaKitPlayerBloc>();
    final playIndex =
        bloc.state.randomPlay == false ? bloc.state.playIndex + action : bloc.state.randomWatch.getIndex();
    if (playIndex < bloc.playItems.length && playIndex >= 0) {
      bloc.add(SetPlayIndex(playIndex: playIndex, debounce: true));
    }
  }

  void _saveWatchTime() {
    final bloc = context.read<MediaKitPlayerBloc>();
    final position = widget.videoState.widget.controller.player.state.position.inSeconds.toInt();
    final duration = widget.videoState.widget.controller.player.state.duration.inSeconds.toInt();
    final id = bloc.playItems[bloc.state.playIndex].id;
    widget.videoState.widget.controller.player.stop();
    widget.saveWatchTime(bloc.state.playIndex, id, position, duration);
  }
}
