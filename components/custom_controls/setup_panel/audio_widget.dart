import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'audio_widget/audio_item_widget.dart';

class AudioWidget extends StatefulWidget {
  final VideoState videoState;
  const AudioWidget({super.key, required this.videoState});

  @override
  State<AudioWidget> createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  final ItemScrollController itemScrollController = ItemScrollController();
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpTo());
    super.initState();
  }

  void _jumpTo() {
    int index = 0;
    if (widget.videoState.widget.controller.player.state.tracks.audio.isNotEmpty) {
      for (var element in widget.videoState.widget.controller.player.state.tracks.audio.indexed) {
        if (widget.videoState.widget.controller.player.state.track.audio.id == element.$2.id) {
          index = element.$1;
        }
      }
      itemScrollController.jumpTo(index: index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.videoState.widget.controller.player.state.tracks.audio.isNotEmpty
        ? Scrollbar(
            child: ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemCount: widget.videoState.widget.controller.player.state.tracks.audio.length,
              itemBuilder: (BuildContext context, int index) {
                final audioItemWidget = AudioItemWidget(
                  videoState: widget.videoState,
                  index: index,
                );
                return index == 0
                    ? CallbackShortcuts(
                        bindings: {const SingleActivator(LogicalKeyboardKey.arrowUp): () {}},
                        child: audioItemWidget,
                      )
                    : audioItemWidget;
              },
            ),
          )
        : const Focus(autofocus: true, child: SizedBox.shrink());
  }
}
