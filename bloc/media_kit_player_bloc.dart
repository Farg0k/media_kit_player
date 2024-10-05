import 'dart:async';

import 'package:bloc_event_transformers/bloc_event_transformers.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../entity/play_item.dart';
import '../../entity/player_settings.dart';
import '../../entity/random_watch.dart';
import '../../services/shared_preferences_service.dart';

part 'media_kit_player_event.dart';
part 'media_kit_player_state.dart';

class MediaKitPlayerBloc extends Bloc<MediaKitPlayerEvent, MediaKitPlayerState> {
  Timer? timer;
  final List<PlayItem> playItems;
  final int playIndex;
  final SharedPreferencesService sharedPreferencesService;
  MediaKitPlayerBloc({required this.playItems, required this.playIndex, required this.sharedPreferencesService})
      : super(MediaKitPlayerState(
          playIndex: playIndex,
          playItems: playItems,
          playerPanel: PlayerPanel.buffering,
          tabIndex: 0,
          settingsItemIndex: 0,
          repeat: Repeat.none,
          playerSettings: sharedPreferencesService.fetchPlayerSettings(),
          randomWatch: RandomWatch(playlistLength: playItems.length),
          boxFit: BoxFit.contain,
        )) {
    on<SetPlayIndex>((event, emit) => _setPlayIndex(event, emit));
    on<SetActivePanel>((event, emit) => _setActivePanel(event, emit));
    on<DebounceActivePanel>(_debounceActivePanel, transformer: debounce(const Duration(seconds: 2)));
    on<SetRandomClocPosition>((event, emit) => _setRandomClocPosition(event, emit));
    on<SetSetupTabIndex>((event, emit) => _setSetupTabIndex(event, emit));
    on<SetSideSheetState>((event, emit) => _setSideSheetState(event, emit));
    on<SetSettingsItemIndex>((event, emit) => _setSettingsItemIndex(event, emit));
    on<SetRepeat>((event, emit) => _setRepeat(event, emit));
    on<SetSleepTimer>((event, emit) => _setSleepTimer(event, emit));
    on<SetSleepTimeLeft>((event, emit) => _setSleepTimeLeft(event, emit));
    on<SetEndPlaybackAndSleep>((event, emit) => _setEndPlaybackAndSleep(event, emit));
    on<SetPlayerSettings>((event, emit) => _setPlayerSettings(event, emit));
    on<SetPlayItems>((event, emit) => _setPlayItems(event, emit));
    on<SetRandomWatch>((event, emit) => _setRandomWatch(event, emit));
    on<SetBoxFit>((event, emit) => _setBoxFit(event, emit));
  }

  void _setPlayIndex(SetPlayIndex event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(
      playIndex: event.playIndex,
      playerPanel: PlayerPanel.info,
    ));
    if (event.debounce == true) {
      add(const DebounceActivePanel(playerPanel: PlayerPanel.none, debouncePanel: PlayerPanel.info));
    }
  }

  void _setActivePanel(SetActivePanel event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(playerPanel: event.playerPanel));
    if (event.debounce == true) {
      add(DebounceActivePanel(playerPanel: PlayerPanel.none, debouncePanel: event.playerPanel));
    }
  }

  void _debounceActivePanel(DebounceActivePanel event, Emitter<MediaKitPlayerState> emit) {
    if (event.debouncePanel == state.playerPanel) {
      emit(state.copyWith(playerPanel: event.playerPanel));
    }
  }

  void _setRandomClocPosition(SetRandomClocPosition event, Emitter<MediaKitPlayerState> emit) {
    final betterPlayerSettings = state.playerSettings.copyWith(clockPosition: event.position);
    emit(state.copyWith(playerSettings: betterPlayerSettings));
  }

  void _setSetupTabIndex(SetSetupTabIndex event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(tabIndex: event.tabIndex));
  }

  void _setSideSheetState(SetSideSheetState event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(sideSheetOpen: event.isOpen));
  }

  void _setSettingsItemIndex(SetSettingsItemIndex event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(settingsItemIndex: event.index));
  }

  void _setRepeat(SetRepeat event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(repeat: event.repeat));
  }

  void _setSleepTimer(SetSleepTimer event, Emitter<MediaKitPlayerState> emit) {
    bool sleepAfter = event.sleepAfter ?? false;
    Duration sleepTime = event.sleepAfter == null ? event.sleepTime ?? Duration.zero : Duration.zero;
    emit(state.copyWith(sleepTime: sleepTime, sleepAfter: sleepAfter));
    if (sleepTime == Duration.zero) {
      timer?.cancel();
    } else {
      timer = Timer.periodic(
        const Duration(minutes: 1),
        (timer) {
          final sleepTime = (state.sleepTime - const Duration(minutes: 1));
          add(SetSleepTimeLeft(sleepTime: sleepTime));
          if (sleepTime == const Duration(minutes: 2)) {
            add(const SetActivePanel(playerPanel: PlayerPanel.sleep));
          }
          if (sleepTime == Duration.zero) {
            timer.cancel();
            add(const SetEndPlaybackAndSleep(endPlaybackAndSleep: true));
          }
        },
      );
    }
  }

  _setSleepTimeLeft(SetSleepTimeLeft event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(sleepTime: event.sleepTime));
  }

  void _setEndPlaybackAndSleep(SetEndPlaybackAndSleep event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(endPlaybackAndSleep: event.endPlaybackAndSleep));
  }

  @override
  Future<void> close() {
    timer?.cancel();
    return super.close();
  }

  void _setPlayerSettings(SetPlayerSettings event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(playerSettings: event.playerSettings, isChangePlayerSettings: event.isChangePlayerSettings));
    sharedPreferencesService.savePlayerSettings(playerSettings: state.playerSettings);
  }

  void _setPlayItems(SetPlayItems event, Emitter<MediaKitPlayerState> emit) {
    List<PlayItem> playItems = state.playItems;
    playItems[state.playIndex] = event.playItem;
    emit(state.copyWith(playItems: playItems));
  }

  void _setRandomWatch(SetRandomWatch event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(randomPlay: event.value));
  }

  void _setBoxFit(SetBoxFit event, Emitter<MediaKitPlayerState> emit) {
    emit(state.copyWith(boxFit: event.value));
  }
}
