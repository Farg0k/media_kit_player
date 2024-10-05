part of 'media_kit_player_bloc.dart';

sealed class MediaKitPlayerEvent extends Equatable {
  const MediaKitPlayerEvent();
}

class SetActivePanel extends MediaKitPlayerEvent {
  final PlayerPanel playerPanel;
  final bool debounce;
  const SetActivePanel({required this.playerPanel, this.debounce = false});

  @override
  List<Object?> get props => [];
}

class SetPlayIndex extends MediaKitPlayerEvent {
  final int playIndex;
  final bool debounce;
  const SetPlayIndex({required this.playIndex, this.debounce = false});

  @override
  List<Object?> get props => [];
}

class DebounceActivePanel extends MediaKitPlayerEvent {
  final PlayerPanel playerPanel;
  final PlayerPanel debouncePanel;
  const DebounceActivePanel({required this.playerPanel, required this.debouncePanel});

  @override
  List<Object?> get props => [];
}

class SetRandomClocPosition extends MediaKitPlayerEvent {
  final int position;
  const SetRandomClocPosition({required this.position});

  @override
  List<Object?> get props => [];
}

class SetSetupTabIndex extends MediaKitPlayerEvent {
  final int tabIndex;
  const SetSetupTabIndex({required this.tabIndex});

  @override
  List<Object?> get props => [];
}

class SetSideSheetState extends MediaKitPlayerEvent {
  final bool isOpen;
  const SetSideSheetState({required this.isOpen});

  @override
  List<Object?> get props => [];
}

class SetSettingsItemIndex extends MediaKitPlayerEvent {
  final int index;
  const SetSettingsItemIndex({required this.index});

  @override
  List<Object?> get props => [];
}

class SetRepeat extends MediaKitPlayerEvent {
  final Repeat repeat;
  const SetRepeat({required this.repeat});

  @override
  List<Object?> get props => [];
}

class SetSleepTimer extends MediaKitPlayerEvent {
  final Duration? sleepTime;
  final bool? sleepAfter;
  const SetSleepTimer({this.sleepTime, this.sleepAfter});

  @override
  List<Object?> get props => [];
}

class SetSleepTimeLeft extends MediaKitPlayerEvent {
  final Duration sleepTime;
  const SetSleepTimeLeft({required this.sleepTime});

  @override
  List<Object?> get props => [];
}

class SetEndPlaybackAndSleep extends MediaKitPlayerEvent {
  final bool endPlaybackAndSleep;
  const SetEndPlaybackAndSleep({required this.endPlaybackAndSleep});

  @override
  List<Object?> get props => [];
}

class SetPlayerSettings extends MediaKitPlayerEvent {
  final PlayerSettings playerSettings;
  final bool? isChangePlayerSettings;
  const SetPlayerSettings({required this.playerSettings, this.isChangePlayerSettings});

  @override
  List<Object?> get props => [];
}

class SetPlayItems extends MediaKitPlayerEvent {
  final PlayItem playItem;
  const SetPlayItems({required this.playItem});

  @override
  List<Object?> get props => [];
}

class SetRandomWatch extends MediaKitPlayerEvent {
  final bool value;
  const SetRandomWatch({required this.value});

  @override
  List<Object?> get props => [];
}

class SetBoxFit extends MediaKitPlayerEvent {
  final BoxFit value;
  const SetBoxFit({required this.value});

  @override
  List<Object?> get props => [];
}