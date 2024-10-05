import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../../utils/players_utils.dart';
import '../../../../bloc/media_kit_player_bloc.dart';

class AudioItemWidget extends StatelessWidget {
  const AudioItemWidget({
    super.key,
    required this.videoState,
    required this.index,
  });

  final VideoState videoState;
  final int index;

  @override
  Widget build(BuildContext context) {
    final element = videoState.widget.controller.player.state.tracks.audio[index];
    bool selected = videoState.widget.controller.player.state.track.audio.id == element.id;
    return Material(
      child: ListTile(
        autofocus: selected,
        selected: selected,
        selectedColor: AppTheme.seedColor,
        focusColor: Theme.of(context).focusColor,
        onTap: () async {
          context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
          await videoState.widget.controller.player.setAudioTrack(element);
        },
        leading: selected == true ? const Icon(Icons.audiotrack) : const Icon(Icons.audiotrack_outlined),
        title: Wrap(
          spacing: 5,
          children: [
            element.title != null
                ? Text(element.title!)
                : Text(
                    element.id.toLowerCase() == 'no' || element.id.toLowerCase() == 'auto'
                        ? element.id
                        : 'AudioTrack #${element.id}',
                  ),
            element.language != null ? Text(element.language!) : const SizedBox.shrink(),
          ],
        ),
        subtitle: Wrap(
          spacing: 5,
          children: [
            element.channels != null ? Text('Audio Channels: ${element.channels}') : const SizedBox.shrink(),
            element.bitrate != null
                ? Text('Bitrate: ${PlayersUtils.parseBitRate(bitrateInt: element.bitrate)}')
                : const SizedBox.shrink(),
            element.samplerate != null ? Text('Sampling rate: ${element.samplerate}Hz') : const SizedBox.shrink(),
          ],
        ),
        trailing: Text(element.codec ?? ''),
      ),
    );
  }
}
