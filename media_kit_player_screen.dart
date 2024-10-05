import 'dart:async';

import 'package:auto_route/annotations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../entity/play_item.dart';
import '../../services/network_requests.dart';
import '../../utils/debouncer.dart';
import '../../utils/locator.dart';
import '../const/player_const.dart';
import '../services/shared_preferences_service.dart';
import '../utils/players_utils.dart';
import 'bloc/media_kit_player_bloc.dart';
import 'components/error_screen.dart';
import 'components/mk_custom_controls.dart';
import 'components/placeholder_widget.dart';

@RoutePage()
class MediaKitPlayerScreen extends StatelessWidget {
  final List<PlayItem> playItems;
  final int playIndex;
  final Function(int, String, int?, int?) saveWatchTime;

  const MediaKitPlayerScreen({
    super.key,
    required this.playItems,
    required this.playIndex,
    required this.saveWatchTime,
  });

  @override
  Widget build(BuildContext context) {
    SharedPreferencesService sharedPreferencesService = SharedPreferencesService();
    return FutureBuilder<bool>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return BlocProvider(
          create: (context) => MediaKitPlayerBloc(
            playItems: playItems,
            playIndex: playIndex,
            sharedPreferencesService: sharedPreferencesService,
          ),
          child: MediaKitPlayerEngine(
            saveWatchTime: saveWatchTime,
          ),
        );
      },
      future: sharedPreferencesService.init(),
    );
  }
}

class MediaKitPlayerEngine extends StatefulWidget {
  final Function(int, String, int?, int?) saveWatchTime;

  const MediaKitPlayerEngine({
    super.key,
    required this.saveWatchTime,
  });

  @override
  State<MediaKitPlayerEngine> createState() => _MediaKitPlayerEngineState();
}

final GlobalKey<VideoState> keyGlobalMKPlayer = GlobalKey<VideoState>();

class _MediaKitPlayerEngineState extends State<MediaKitPlayerEngine> {
  late final Player player = Player();
  late final VideoController controller = VideoController(player);

  String? isError;
  bool isStart = true;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    //WidgetsBinding.instance.addObserver(this);//todo??
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    //WidgetsBinding.instance.removeObserver(this);//todo??
    player.dispose();
    super.dispose();
  }

  Future<bool> _startPlayItem({
    required List<PlayItem> playItems,
    required int playIndex,
  }) async {
    final bloc = context.read<MediaKitPlayerBloc>();
    PlayItem playItem = playItems[playIndex];
    if (playItem.mediaUrl != null && playItem.directLink != true && playItem.parserHub != null) {
      try {
        playItem = await playItem.parserHub!.getStreams(playItem: playItem);
        bloc.add(SetPlayItems(playItem: playItem));
      } catch (e) {
        isError = e.toString();
        return false;
      }
    }
    String? mediaUrl = await _getDefaultMediaUrl(playItem);
    if (mediaUrl == null) {
      isError = 'url is empty!';
      return false;
    }
    Map<String, String>? headers = (playItem.videoItems ?? []).isNotEmpty ? playItem.videoItems!.first.headers : null;
    await player.open(
      Media(
        mediaUrl,
        start: playItems[playIndex].watchedMarker?.position != null && isStart == true
            ? Duration(seconds: playItems[playIndex].watchedMarker!.position!)
            : null,
        httpHeaders: headers,
      ),
    );
    isStart == true ? isStart = false : isStart = false;
    controller.player.stream.completed.listen(
      (event) {
        if (event == true) {
          locator<Debouncer>().runThrottler(() {
            _onFinished();
          }, const Duration(milliseconds: 800));
        }
      },
    );
    StreamSubscription? subscription;
    bloc.add(const SetActivePanel(playerPanel: PlayerPanel.buffering));
    subscription = controller.player.stream.duration.listen(
      (event) async {
        if (event.inSeconds > 0) {
          await setExtItems();
          bloc.add(const SetActivePanel(playerPanel: PlayerPanel.info, debounce: true));
          subscription?.cancel();
        }
      },
    );
    return true;
  }

  Future<String?> _getDefaultMediaUrl(PlayItem playItem) async {
    if (playItem.mediaUrl != null && playItem.directLink == true) {
      final url = playItem.mediaUrl!;
      bool isAvailability = await locator<NetworkRequests>().checkFileAvailability(url);
      return isAvailability == true ? playItem.mediaUrl! : null;
    }
    if ((playItem.videoItems ?? []).isNotEmpty) {
      var defaultVideoItem = playItem.videoItems!.firstWhere(
            (e) => e.defaultPath == true,
        orElse: () => playItem.videoItems!.last,
      );
      bool isAvailability = await locator<NetworkRequests>().checkFileAvailability(defaultVideoItem.path);
      if (isAvailability == true) {
        return defaultVideoItem.path;
      } else {
        playItem.videoItems!.remove(defaultVideoItem);
        if (playItem.videoItems!.isNotEmpty) {
          return _getDefaultMediaUrl(playItem);
        }
      }
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        body: BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
          buildWhen: (oldState, newState) => oldState.playIndex != newState.playIndex,
          builder: (context, state) {
            return FutureBuilder<bool>(
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return PlaceholderWidget(
                    placeholderImg: state.playItems[state.playIndex].placeholderImg,
                    text: 'Loading...',
                  );
                }
                if (snapshot.data == false) {
                  return ErrorScreen(isError: isError ?? '');
                }
                if (snapshot.data == true) {
                  return BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
                    buildWhen: (oldState, newState) => oldState.boxFit != newState.boxFit,
                    builder: (context, state) {
                      return Video(
                        key: keyGlobalMKPlayer,
                        controller: controller,
                        fit: state.boxFit,
                        wakelock: false,
                        controls: (VideoState videoState) => MediaKitCustomControls(
                          videoState: videoState,
                          saveWatchTime: widget.saveWatchTime,
                        ),
                        subtitleViewConfiguration: SubtitleViewConfiguration(
                          style: TextStyle(
                            fontSize: state.playerSettings.subtitleFontSize,
                            color: PlayerConst.colorList[state.playerSettings.subtitleFontColor],
                            backgroundColor: PlayerConst.colorList[state.playerSettings.subtitleBackgroundColor],
                          ),
                          textAlign: TextAlign.start,
                          padding: EdgeInsets.fromLTRB(
                            state.playerSettings.subtitleLeftPadding,
                            5,
                            state.playerSettings.subtitleRightPadding,
                            state.playerSettings.subtitleBottomPadding,
                          ),
                        ),
                      );
                    },
                  );
                }
                return PlaceholderWidget(
                  placeholderImg: state.playItems[state.playIndex].placeholderImg,
                  text: 'Loading...',
                );
              },
              future: _startPlayItem(
                playItems: state.playItems,
                playIndex: state.playIndex,
              ),
            );
          },
        ),
      ),
    );
  }

  void _onPopInvoked(canPop, result) {
    if (isError != null) {
      Navigator.pop(context);
    } else if (canPop == false) {
      final playerPanel = context.read<MediaKitPlayerBloc>().state.playerPanel;
      if (playerPanel == PlayerPanel.none) {
        final position = controller.player.state.position.inSeconds.toInt();
        final duration = controller.player.state.duration.inSeconds.toInt();
        _saveWatchTime(position, duration);
        controller.player.stop();
      }
      playerPanel == PlayerPanel.none
          ? Navigator.pop(context)
          : context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
    }
  }

  void _saveWatchTime(int? position, int? duration) {
    final playIndex = context.read<MediaKitPlayerBloc>().state.playIndex;
    final playItems = context.read<MediaKitPlayerBloc>().state.playItems;
    final id = playItems[playIndex].id;
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.saveWatchTime(playIndex, id, position, duration));
  }

  void _onFinished() {
    final bloc = context.read<MediaKitPlayerBloc>();
    final state = bloc.state;
    final position = controller.player.state.position.inSeconds.toInt();
    final duration = controller.player.state.duration.inSeconds.toInt();
    _saveWatchTime(position, duration);

    if (state.playIndex < state.playItems.length - 1) {
      if (state.repeat == Repeat.one) {
        controller.player
          ..seek(const Duration(seconds: 0))
          ..play();
      } else {
        final playIndex = bloc.state.randomPlay == false ? bloc.state.playIndex + 1 : bloc.state.randomWatch.getIndex();
        bloc.add(SetPlayIndex(playIndex: playIndex, debounce: true));
      }
    } else {
      _handleEndOfPlayback(bloc);
    }
    if (state.sleepAfter == true) {
      _endPlaybackAndSleep(bloc);
    }
  }

  void _handleEndOfPlayback(MediaKitPlayerBloc bloc) {
    if (bloc.state.repeat == Repeat.all) {
      bloc.add(const SetPlayIndex(playIndex: 0, debounce: true));
    } else {
      _endPlayback(bloc);
    }
  }

  void _endPlaybackAndSleep(MediaKitPlayerBloc bloc) {
    _endPlayback(bloc);
    PlayersUtils.sleepTimerExec();
  }

  void _endPlayback(MediaKitPlayerBloc bloc) {
    bloc.add(const SetActivePanel(playerPanel: PlayerPanel.none));
    if (bloc.state.sideSheetOpen == true) {
      Navigator.pop(context);
    }
    Navigator.pop(context);
  }

  Future<void> setExtItems() async {
    final playIndex = context.read<MediaKitPlayerBloc>().state.playIndex;
    final playItems = context.read<MediaKitPlayerBloc>().state.playItems;
    final audioItems = playItems[playIndex].extAudioItemList;
    audioItems?.forEach((e) async {
      await player.setAudioTrack(
        AudioTrack.uri(
          e.path,
          title: 'External audio track: ${e.title}',
          language: e.language,
        ),
      );
    });
    await player.setAudioTrack(AudioTrack.auto());

    final subtitleItems = playItems[playIndex].extSubtitleItemList;
    subtitleItems?.forEach((e) async {
      if (e.loadSub == false) {
        await player.setSubtitleTrack(
          SubtitleTrack.uri(
            e.path,
            title: 'External subtitle: ${e.title}',
            language: e.language,
          ),
        );
      }
    });
    await player.setSubtitleTrack(SubtitleTrack.auto());
  }
}
