import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../../../entity/play_item.dart';
import '../../../../../utils/players_utils.dart';
import '../../../../bloc/media_kit_player_bloc.dart';

class PlaylistItemWidget extends StatelessWidget {
  const PlaylistItemWidget({
    super.key,
    required this.videoState,
    required this.item,
    required this.index,
    required this.autofocus,
    required this.saveWatchTime,
  });

  final VideoState videoState;
  final PlayItem item;
  final int index;
  final bool autofocus;
  final Function(int, String, int?, int?) saveWatchTime;

  void _saveWatchTime({required BuildContext context}) {
    final bloc = context.read<MediaKitPlayerBloc>();
    final position = videoState.widget.controller.player.state.position.inSeconds.toInt();
    final duration = videoState.widget.controller.player.state.duration.inSeconds.toInt();
    final id = bloc.playItems[bloc.state.playIndex].id;
    saveWatchTime(bloc.state.playIndex, id, position, duration);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        autofocus: autofocus,
        selectedColor: AppTheme.seedColor,
        focusColor: Theme.of(context).focusColor,
        selected: autofocus,
        onTap: () {
          _saveWatchTime(context: context);
          context.read<MediaKitPlayerBloc>().add(SetPlayIndex(playIndex: index, debounce: true));
        },
        leading: autofocus
            ? videoState.widget.controller.player.state.playing == true
                ? const Icon(Icons.play_arrow)
                : const Icon(Icons.pause)
            : item.liveStream
                ? const Icon(Icons.tv)
                : const Icon(Icons.movie),
        title: Text(item.fileName ?? item.title),
        trailing: item.watchedMarker != null ? const Icon(Icons.remove_red_eye) : null,
        subtitle: item.watchedMarker?.position != null &&
                item.watchedMarker?.duration != null &&
                item.watchedMarker?.duration != 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('${((item.watchedMarker!.position! / item.watchedMarker!.duration!) * 100).round()}%'),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: item.watchedMarker!.position! / item.watchedMarker!.duration!,
                    ),
                  ),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      text: PlayersUtils.formatDuration(duration: Duration(seconds: item.watchedMarker!.position!)),
                      children: <TextSpan>[
                        const TextSpan(text: ' / '),
                        TextSpan(
                            text: PlayersUtils.formatDuration(
                                duration: Duration(seconds: item.watchedMarker!.duration!))),
                      ],
                    ),
                    textAlign: TextAlign.end,
                  )
                ],
              )
            : item.watchedMarker?.position != null
                ? RichText(
                    text: TextSpan(
                      text: PlayersUtils.formatDuration(duration: Duration(seconds: item.watchedMarker!.position!)),
                      children: const <TextSpan>[
                        TextSpan(text: ' / '),
                        TextSpan(text: '--:--'),
                      ],
                    ),
                    textAlign: TextAlign.end,
                  )
                : null,
      ),
    );
  }
}
