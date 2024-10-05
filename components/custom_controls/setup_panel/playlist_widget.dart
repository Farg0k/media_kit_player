import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../bloc/media_kit_player_bloc.dart';
import 'playlist_widget/playlist_item_widget.dart';

class PlaylistWidget extends StatefulWidget {
  final VideoState videoState;

  final Function(int, String, int?, int?) saveWatchTime;
  const PlaylistWidget({super.key, required this.videoState, required this.saveWatchTime});

  @override
  State<PlaylistWidget> createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<PlaylistWidget> {
  final ItemScrollController itemScrollController = ItemScrollController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => itemScrollController.jumpTo(index: context.read<MediaKitPlayerBloc>().state.playIndex));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
      buildWhen: (oldState, newState) => oldState.playIndex != newState.playIndex,
      builder: (context, state) {
        return Scrollbar(
          child: ScrollablePositionedList.builder(
            itemScrollController: itemScrollController,
            itemCount: state.playItems.length,
            itemBuilder: (BuildContext context, int index) {
              final item = state.playItems[index];
              final playlistItemWidget = PlaylistItemWidget(
                videoState: widget.videoState,
                item: item,
                index: index,
                autofocus: index == state.playIndex,
                saveWatchTime: widget.saveWatchTime,
              );
              return index == 0
                  ? CallbackShortcuts(
                      bindings: {const SingleActivator(LogicalKeyboardKey.arrowUp): () {}},
                      child: playlistItemWidget,
                    )
                  : playlistItemWidget;
            },
          ),
        );
      },
    );
  }
}
