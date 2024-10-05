import 'dart:math';

import '../../../utils/string_utils.dart';

import '../../../../app_theme/app_theme.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../const/player_const.dart';
import '../../bloc/media_kit_player_bloc.dart';

class ClockPanel extends StatelessWidget {
  final VideoState videoState;

  const ClockPanel({super.key, required this.videoState});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
      buildWhen: (oldState, newState) =>
          oldState.playerSettings != newState.playerSettings ||
          oldState.sleepTime != newState.sleepTime ||
          oldState.sleepAfter != newState.sleepAfter,
      builder: (context, state) {
        final clockPosition = _getPosition(context: context, index: state.playerSettings.clockPosition);
        return ClockPosition.values[state.playerSettings.clockPosition] == ClockPosition.none
            ? const SizedBox.shrink()
            : Positioned(
                right: clockPosition.$1,
                left: clockPosition.$2,
                top: clockPosition.$3,
                bottom: clockPosition.$4,
                child: Container(
                  width: 65,
                  padding: const EdgeInsets.all(2.0),
                  decoration: BoxDecoration(
                    color: state.playerSettings.showClockBackground == true ? Colors.black26 : null,
                    border: state.playerSettings.showClockBorder == true
                        ? Border.all(color: Theme.of(context).dividerColor)
                        : null,
                    borderRadius: AppTheme.borderRadius,
                  ),
                  child: StreamBuilder(
                      stream: Stream.periodic(const Duration(seconds: 1)),
                      builder: (context, snapshot) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('HH:mm').format(DateTime.now()),
                              style: TextStyle(
                                color: PlayerConst.colorList[state.playerSettings.clockColor],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            LinearProgressIndicator(
                              value: _getPercentage(),
                              color: Colors.blue,
                              backgroundColor: Colors.grey,
                              minHeight: 4,
                            ),
                            state.sleepAfter == true
                                ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      const Icon(
                                        Icons.access_time_filled_outlined,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      Text(
                                        'After File',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: Colors.white,
                                              fontSize: 10,
                                            ),
                                      )
                                    ],
                                  )
                                : state.sleepTime != Duration.zero
                                    ? FittedBox(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                          children: [
                                            Icon(
                                              Icons.access_time_filled_outlined,
                                              size: 15,
                                              color: state.sleepTime < const Duration(minutes: 4)
                                                  ? Colors.orange
                                                  : Colors.white.withOpacity(0.5),
                                            ),
                                            Text(
                                              state.sleepTime.toString().durationClear(),
                                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                    color: state.sleepTime < const Duration(minutes: 4)
                                                        ? Colors.orange
                                                        : Colors.white.withOpacity(0.5),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : videoState.widget.controller.player.state.duration.inSeconds > 0
                                        ? Text(
                                            _getTimeLeft(),
                                            style: TextStyle(
                                              color: PlayerConst.colorList[state.playerSettings.clockColor],
                                            ),
                                          )
                                        : const SizedBox.shrink()
                          ],
                        );
                      }),
                ),
              );
      },
    );
  }

  (double?, double?, double?, double?) _getPosition({required int index, required BuildContext context}) {
    ClockPosition clockPosition = ClockPosition.values[index];
    if (clockPosition == ClockPosition.random) {
      int random = Random().nextInt(4);
      clockPosition = ClockPosition.values[random];
    }
    final right = clockPosition == ClockPosition.topRight || clockPosition == ClockPosition.bottomRight ? 10.0 : null;
    final left = clockPosition == ClockPosition.topLeft || clockPosition == ClockPosition.bottomLeft ? 10.0 : null;
    final top = clockPosition == ClockPosition.topRight || clockPosition == ClockPosition.topLeft ? 10.0 : null;
    final bottom =
        clockPosition == ClockPosition.bottomLeft || clockPosition == ClockPosition.bottomRight ? 10.0 : null;
    return (right, left, top, bottom);
  }

  double _getPercentage() => videoState.widget.controller.player.state.duration.inSeconds.toInt() != 0 ?
      videoState.widget.controller.player.state.position.inSeconds.toInt() /
      videoState.widget.controller.player.state.duration.inSeconds.toInt() : 0;

  String _getTimeLeft() {
    String timeLeft = '';
    final position = videoState.widget.controller.player.state.position.inSeconds.toInt();
    final duration = videoState.widget.controller.player.state.duration.inSeconds.toInt();
    var seconds = duration - position;
    timeLeft = Duration(seconds: seconds).toString().split('.')[0];
    timeLeft = timeLeft.substring(0, timeLeft.length - 3);
    return timeLeft;
  }
}
