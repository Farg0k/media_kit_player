import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../entity/play_item.dart';
import '../../../../utils/players_utils.dart';
import '../../../bloc/media_kit_player_bloc.dart';
import 'video_widget/video_item_widget.dart';

class VideoWidget extends StatefulWidget {
  final VideoState videoState;
  const VideoWidget({super.key, required this.videoState});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  final ItemScrollController itemScrollController = ItemScrollController();
  List<dynamic> video = [];

  @override
  void initState() {
    video.addAll(widget.videoState.widget.controller.player.state.tracks.video);
    final playIndex = context.read<MediaKitPlayerBloc>().state.playIndex;
    final playItems = context.read<MediaKitPlayerBloc>().state.playItems;
    final videoItems = playItems[playIndex].videoItems;
    videoItems?.forEach((e) {
      video.add(e);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpTo());
    super.initState();
  }

  void _jumpTo() {
    int index = 0;
    if (widget.videoState.widget.controller.player.state.tracks.video.isNotEmpty) {
      for (var element in widget.videoState.widget.controller.player.state.tracks.video.indexed) {
        if (widget.videoState.widget.controller.player.state.track.video.id == element.$2.id) {
          index = element.$1;
        }
      }
      itemScrollController.jumpTo(index: index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return video.isNotEmpty
        ? Scrollbar(
            child: ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemCount: video.length,
              itemBuilder: (BuildContext context, int index) {
                Widget videoItem = Container();
                if (video[index].runtimeType == VideoTrack) {
                  VideoTrack element = video[index];
                  videoItem = VideoItemWidget(
                    videoState: widget.videoState,
                    index: index,
                    element: element,
                  );
                }
                if (video[index].runtimeType == VideoItem) {
                  VideoItem element = video[index];
                  videoItem = Material(
                    child: ListTile(
                      focusColor: Theme.of(context).focusColor,
                      onTap: () async {
                        context.read<MediaKitPlayerBloc>().add(const SetActivePanel(playerPanel: PlayerPanel.none));
                        final position = widget.videoState.widget.controller.player.state.position;
                        await widget.videoState.widget.controller.player.open(
                          Media(
                            element.path,
                            start: position,
                            httpHeaders: element.headers,
                          ),
                        );
                      },
                      leading: PlayersUtils.getIcon(width: int.tryParse(element.title)),
                      title: Text(element.title),
                      subtitle: element.description != null ? Text(element.description!) : null,
                    ),
                  );
                }
                return index == 0
                    ? CallbackShortcuts(
                        bindings: {const SingleActivator(LogicalKeyboardKey.arrowUp): () {}},
                        child: videoItem,
                      )
                    : videoItem;
              },
            ),
          )
        : const Focus(autofocus: true, child: SizedBox.shrink());
  }
}
