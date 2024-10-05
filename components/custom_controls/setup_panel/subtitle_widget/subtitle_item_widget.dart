import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../bloc/media_kit_player_bloc.dart';

class SubtitleItemWidget extends StatelessWidget {
  const SubtitleItemWidget({
    super.key,
    required this.videoState,
    required this.index,
  });

  final VideoState videoState;

  final int index;

  @override
  Widget build(BuildContext context) {
    final element = videoState.widget.controller.player.state.tracks.subtitle[index];
    final selected = videoState.widget.controller.player.state.track.subtitle.id == element.id;
    String name = element.id == 'auto'
        ? 'auto'
        : element.id == 'no'
            ? 'no'
            : element.title ?? element.language ?? 'n/a';
    return Material(
      child: ListTile(
        autofocus: selected,
        selected: selected,
        selectedColor: AppTheme.seedColor,
        focusColor: Theme.of(context).focusColor,
        onTap: () async {
          context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
          await videoState.widget.controller.player.setSubtitleTrack(element);
        },
        leading: element.id == 'no'
            ? const Icon(Icons.subtitles_off_outlined)
            : selected == true
                ? const Icon(Icons.subtitles)
                : const Icon(Icons.subtitles_outlined),
        title: Text(name),
        subtitle: element.codec != null ? Text('type:${element.codec}') : null,
      ),
    );
  }
}
