import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../app_theme/app_theme.dart';
import '../../../utils/players_utils.dart';

import '../../bloc/media_kit_player_bloc.dart';
import 'time_line_panel.dart';

class InfoPanel extends StatelessWidget {
  final VideoState videoState;
  const InfoPanel({super.key, required this.videoState});

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
              buildWhen: (oldState, newState) => oldState.playIndex != newState.playIndex,
              builder: (context, state) {
                final playItem = state.playItems[state.playIndex];
                return Container(
                  constraints: BoxConstraints(
                    minHeight: 130,
                    maxWidth: MediaQuery.of(context).size.width,
                  ),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.backgroundColor),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          playItem.coverImg != null
                              ? Column(
                                  children: [
                                    Container(
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(borderRadius: AppTheme.borderRadius),
                                      constraints: const BoxConstraints(maxWidth: 120),
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        width: 120,
                                        imageUrl: playItem.coverImg!,
                                      ),
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink(),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          playItem.title,
                                          style:
                                              Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                      state.randomPlay == true ? const Icon(Icons.shuffle) : const SizedBox.shrink(),
                                      state.repeat == Repeat.none
                                          ? const SizedBox.shrink()
                                          : state.repeat == Repeat.one
                                              ? const Icon(Icons.repeat_one)
                                              : const Icon(Icons.repeat),
                                      const Icon(Icons.speed),
                                      Text('${videoState.widget.controller.player.state.rate}x '),
                                      PlayersUtils.getIcon(width: videoState.widget.controller.player.state.width),
                                      Icon(playItem.liveStream == true ? Icons.live_tv : Icons.movie),
                                      SizedBox(width: 5),
                                      Container(
                                        height: 30,
                                        width: 30,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                          borderRadius: AppTheme.borderRadius,
                                          image: playItem.parserHub!.source.logo.isNotEmpty
                                              ? DecorationImage(
                                                  image: AssetImage(playItem.parserHub!.source.logo),
                                                  fit: BoxFit.fill,
                                                )
                                              : null,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black26,
                                          border: Border.all(color: Theme.of(context).dividerColor),
                                          borderRadius: AppTheme.borderRadius,
                                        ),
                                        padding: EdgeInsets.all(3),
                                        child: Text(
                                          'MK',
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                  playItem.subTitle != null
                                      ? Text(
                                          playItem.subTitle!,
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey),
                                        )
                                      : const SizedBox.shrink(),
                                  playItem.fileName != null
                                      ? Text(
                                          playItem.fileName!,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                                        )
                                      : const SizedBox.shrink(),
                                  Text(
                                    playItem.description ?? '',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      TimeLinePanel(videoState: videoState),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
