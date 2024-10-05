import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../app_theme/app_theme.dart';
import '../../../../generated/l10n.dart';
import '../../bloc/media_kit_player_bloc.dart';
import 'setup_panel/audio_widget.dart';
import 'setup_panel/playlist_widget.dart';
import 'setup_panel/settings_screen.dart';
import 'setup_panel/subtitle_widget.dart';
import 'setup_panel/video_widget.dart';
import 'time_line_panel.dart';

class SetupPanel extends StatefulWidget {
  final VideoState videoState;
  final Function(int, String, int?, int?) saveWatchTime;
  final int selSettingsTab;
  const SetupPanel({super.key, required this.videoState, required this.selSettingsTab, required this.saveWatchTime});

  @override
  State<SetupPanel> createState() => _SetupPanelState();
}

class _SetupPanelState extends State<SetupPanel> with TickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, IconData> tabs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this, initialIndex: widget.selSettingsTab);
  }

  @override
  Widget build(BuildContext context) {
    tabs = {
      S.of(context).playlist: Icons.playlist_play_sharp,
      S.of(context).video: Icons.personal_video_outlined,
      S.of(context).audio: Icons.audiotrack_rounded,
      S.of(context).subtitle: Icons.subtitles,
      S.of(context).settings: Icons.settings,
    };
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _arrowFunction(action: 1),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _arrowFunction(action: -1),
        const SingleActivator(LogicalKeyboardKey.contextMenu): () =>
            context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none)),
        const SingleActivator(LogicalKeyboardKey.keyQ): () =>
            context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none)),
      },
      child: Stack(
        children: [
          BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
            buildWhen: (oldState, newState) => oldState.playIndex != newState.playIndex,
            builder: (context, state) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppTheme.backgroundColor),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TabBar(
                      controller: _tabController,
                      tabs: tabs.entries
                          .map((e) => Tab(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(e.value),
                                    const SizedBox(width: 8),
                                    Text(e.key),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          PlaylistWidget(
                            videoState: widget.videoState,
                            saveWatchTime: widget.saveWatchTime,
                          ),
                          VideoWidget(videoState: widget.videoState),
                          AudioWidget(videoState: widget.videoState),
                          SubtitleWidget(videoState: widget.videoState),
                          SettingsScreen(videoState: widget.videoState),
                        ],
                      ),
                    ),
                    TimeLinePanel(videoState: widget.videoState),
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  _arrowFunction({required int action}) {
    final value = _tabController.index + action < 0
        ? _tabController.length - 1
        : _tabController.index + action == _tabController.length
            ? 0
            : _tabController.index + action;
    context.read<MediaKitPlayerBloc>().add(SetSetupTabIndex(tabIndex: value));
    _tabController.animateTo(value);
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.focusedChild?.unfocus();
    }
  }
}
