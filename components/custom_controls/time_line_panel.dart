import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../utils/players_utils.dart';

class TimeLinePanel extends StatelessWidget {
  final VideoState videoState;
  const TimeLinePanel({super.key, required this.videoState});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('HH:mm').format(DateTime.now()),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  videoState.widget.controller.player.state.buffering == false ? Text(
                    '''${(PlayersUtils.getPercentage(
                          videoState.widget.controller.player.state.duration,
                          videoState.widget.controller.player.state.position,
                        ) * 100).round()}%''',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18),
                  ) : const SizedBox.shrink(),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  videoState.widget.controller.player.state.playing == true
                      ? const Icon(Icons.play_arrow)
                      : const Icon(Icons.pause),
                  Expanded(
                    child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                      return Stack(
                        children: [
                          Container(color: Colors.white, height: 10),
                          Container(
                            color: Colors.grey,
                            height: 10,
                            width: constraints.maxWidth *
                                (PlayersUtils.getPercentage(
                                  videoState.widget.controller.player.state.duration,
                                  videoState.widget.controller.player.state.buffer,
                                )),
                          ),
                          Container(
                            color: Colors.blue,
                            height: 10,
                            width: constraints.maxWidth *
                                (PlayersUtils.getPercentage(
                                  videoState.widget.controller.player.state.duration,
                                  videoState.widget.controller.player.state.position,
                                )),
                          )
                        ],
                      );
                    }),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _getTimeLeft(),
                    style: const TextStyle(color: Colors.white, fontSize: 17),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        PlayersUtils.formatDuration(duration: videoState.widget.controller.player.state.position),
                        style: const TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      const Text(
                        ' / ',
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                      Text(
                        PlayersUtils.formatDuration(
                          duration: videoState.widget.controller.player.state.duration,
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _getTimeLeft() {
    final position = videoState.widget.controller.player.state.position.inSeconds.toInt();
    final duration = videoState.widget.controller.player.state.duration.inSeconds.toInt();
    String timeLeft = Duration(seconds: duration - position).toString().split('.')[0];
    return timeLeft;
  }
}
