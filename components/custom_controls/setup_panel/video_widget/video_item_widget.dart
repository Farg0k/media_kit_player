import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../../utils/players_utils.dart';
import '../../../../bloc/media_kit_player_bloc.dart';

class VideoItemWidget extends StatelessWidget {
  const VideoItemWidget({
    super.key,
    required this.videoState,
    required this.index,
    required this.element
  });

  final VideoState videoState;
  final int index;
  final VideoTrack element;

  @override
  Widget build(BuildContext context) {
    final selected = videoState.widget.controller.player.state.track.video.id == element.id;
    String name = element.id == 'auto'
        ? 'auto'
        : element.id == 'no'
            ? 'no'
            : '${element.w}x${element.h}';
    if (element.w != null) {
      if (element.w! > 4000) {
        name = 'UHD $name';
      } else if (element.w! > 1000) {
        name = 'HD $name';
      } else if (element.w! > 0) {
        name = 'SD $name';
      }
    }
    String? bitrateStr = PlayersUtils.parseBitRate(bitrateInt: element.bitrate);

    return Material(
      child: ListTile(
        autofocus: selected,
        selected: selected,
        selectedColor: AppTheme.seedColor,
        focusColor: Theme.of(context).focusColor,
        onTap: () async {
          context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
          await videoState.widget.controller.player.setVideoTrack(element);
        },
        leading: PlayersUtils.getIcon(width: element.w),
        title: Text(name),
        subtitle: Wrap(
          spacing: 5,
          children: [
            element.fps != null ? Text('fps:${element.fps?.toStringAsFixed(3)}') : const SizedBox.shrink(),
            bitrateStr != null ? Text(bitrateStr) : const SizedBox.shrink(),
          ],
        ),
        trailing: element.codec != null ? Text(element.codec!) : null,
      ),
    );
  }
}
