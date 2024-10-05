part of 'media_kit_player_bloc.dart';

final class MediaKitPlayerState extends Equatable {
  final int playIndex;
  final List<PlayItem> playItems;
  final PlayerPanel playerPanel;
  final Repeat repeat;
  final PlayerSettings playerSettings;
  final bool sideSheetOpen;
  final Duration sleepTime;
  final bool sleepAfter;
  final int tabIndex;
  final int settingsItemIndex;
  final bool endPlaybackAndSleep;
  final bool? isChangePlayerSettings;
  final RandomWatch randomWatch;
  final bool randomPlay;
  final BoxFit boxFit;
  const MediaKitPlayerState({
    required this.playIndex,
    required this.playItems,
    required this.playerPanel,
    required this.repeat,
    required this.playerSettings,
    this.sideSheetOpen = false,
    this.sleepTime = Duration.zero,
    this.sleepAfter = false,
    required this.tabIndex,
    required this.settingsItemIndex,
    this.endPlaybackAndSleep = false,
    this.isChangePlayerSettings,
    required this.randomWatch,
    this.randomPlay = false,
    required this.boxFit,
  });

  @override
  List<Object?> get props => [
        playIndex,
        playerPanel,
        tabIndex,
        repeat,
        playerSettings,
        settingsItemIndex,
        isChangePlayerSettings,
        sleepTime,
        sleepAfter,
        endPlaybackAndSleep,
        sideSheetOpen,
        randomPlay,
        boxFit,
      ];

  MediaKitPlayerState copyWith({
    int? playIndex,
    List<PlayItem>? playItems,
    PlayerPanel? playerPanel,
    Repeat? repeat,
    PlayerSettings? playerSettings,
    bool? buffering,
    bool? sideSheetOpen,
    Duration? sleepTime,
    bool? sleepAfter,
    int? tabIndex,
    int? settingsItemIndex,
    bool? endPlaybackAndSleep,
    bool? isChangePlayerSettings,
    RandomWatch? randomWatch,
    bool? randomPlay,
    BoxFit? boxFit,
  }) {
    return MediaKitPlayerState(
      playIndex: playIndex ?? this.playIndex,
      playItems: playItems ?? this.playItems,
      playerPanel: playerPanel ?? this.playerPanel,
      repeat: repeat ?? this.repeat,
      playerSettings: playerSettings ?? this.playerSettings,
      sideSheetOpen: sideSheetOpen ?? this.sideSheetOpen,
      sleepTime: sleepTime ?? this.sleepTime,
      sleepAfter: sleepAfter ?? this.sleepAfter,
      tabIndex: tabIndex ?? this.tabIndex,
      settingsItemIndex: settingsItemIndex ?? this.settingsItemIndex,
      endPlaybackAndSleep: endPlaybackAndSleep ?? this.endPlaybackAndSleep,
      isChangePlayerSettings: isChangePlayerSettings,
      randomWatch: randomWatch ?? this.randomWatch,
      randomPlay: randomPlay ?? this.randomPlay,
      boxFit: boxFit ?? this.boxFit,
    );
  }

  @override
  String toString() {
    return '''
    MediaKitPlayerState{
      playIndex: $playIndex, 
      playItems: $playItems,
      playerPanel: $playerPanel,
      repeat: $repeat,
      playerSettings: $playerSettings,
      sideSheetOpen: $sideSheetOpen,
      sleepTime: $sleepTime,
      sleepAfter: $sleepAfter,
      endPlaybackAndSleep: $endPlaybackAndSleep,
      randomWatch: $randomWatch,
      randomPlay: $randomPlay,
      boxFit: $boxFit,
    }''';
  }
}

enum Repeat { none, one, all }

enum PlayerPanel { none, info, simple, setup, sleep, buffering }

enum ClockPosition {
  topRight("Top Right", 0),
  bottomRight("Bottom Right", 1),
  topLeft("Top Left", 2),
  bottomLeft("Bottom Left", 3),
  random("Random", 4),
  none("None", 5);

  const ClockPosition(this.title, this.idx);
  final String title;
  final int idx;
}
