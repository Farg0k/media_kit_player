import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../../app_theme/app_theme.dart';
import '../../../../../entity/play_item.dart';
import '../../../bloc/media_kit_player_bloc.dart';
import 'subtitle_widget/subtitle_item_widget.dart';

class SubtitleWidget extends StatefulWidget {
  final VideoState videoState;
  const SubtitleWidget({super.key, required this.videoState});

  @override
  State<SubtitleWidget> createState() => _SubtitleWidgetState();
}

class _SubtitleWidgetState extends State<SubtitleWidget> {
  final ItemScrollController itemScrollController = ItemScrollController();

  List<dynamic> subtitle = [];
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpTo());
    final playIndex = context.read<MediaKitPlayerBloc>().state.playIndex;
    final playItems = context.read<MediaKitPlayerBloc>().state.playItems;
    List<ExtSubtitleItem> extSubtitleItemList =
        playItems[playIndex].extSubtitleItemList?.where((e) => e.loadSub == true).toList() ?? [];
    subtitle.addAll(widget.videoState.widget.controller.player.state.tracks.subtitle);
    subtitle.addAll(extSubtitleItemList);
    super.initState();
  }

  void _jumpTo() {
    if (widget.videoState.widget.controller.player.state.tracks.subtitle.isNotEmpty) {
      int? index;
      for (var element in widget.videoState.widget.controller.player.state.tracks.subtitle.indexed) {
        if (widget.videoState.widget.controller.player.state.track.subtitle.id == element.$2.id) {
          index = element.$1;
        }
      }
      if (index != null) {
        itemScrollController.jumpTo(index: index);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return subtitle.isNotEmpty
        ? Scrollbar(
            child: ScrollablePositionedList.builder(
              itemScrollController: itemScrollController,
              itemCount: subtitle.length,
              itemBuilder: (BuildContext context, int index) {
                Widget subtitleItemWidget = Container();
                if (subtitle[index].runtimeType == SubtitleTrack) {
                  subtitleItemWidget = SubtitleItemWidget(
                    videoState: widget.videoState,
                    index: index,
                  );
                }
                if (subtitle[index].runtimeType == ExtSubtitleItem) {
                  ExtSubtitleItem element = subtitle[index];
                  subtitleItemWidget = Material(
                    child: ListTile(
                      selectedColor: AppTheme.seedColor,
                      focusColor: Theme.of(context).focusColor,
                      onTap: () async {
                        if (element.loadSub == true) {
                          final bloc = context.read<MediaKitPlayerBloc>();
                          final playIndex = bloc.state.playIndex;
                          final playItems = bloc.state.playItems;
                          if (playItems[playIndex].parserHub?.source.name == 'youtube') {
                            final subtitleString =
                                await playItems[playIndex].parserHub?.youtubeParser.getWebvtt(url: element.path);
                            if (subtitleString != null) {
                              bloc.add(const SetActivePanel(playerPanel: PlayerPanel.none));
                              await widget.videoState.widget.controller.player.setSubtitleTrack(
                                SubtitleTrack.data(
                                  subtitleString,
                                  title: element.title,
                                  language: element.language,
                                ),
                              );
                            }
                          }
                        }
                      },
                      leading: const Icon(Icons.subtitles_outlined),
                      title: Text(element.title),
                      subtitle: element.language != null ? Text(element.language!) : null,
                      trailing: element.loadSub == true ? const Icon(Icons.file_download) : null,
                    ),
                  );
                }
                return index == 0
                    ? CallbackShortcuts(
                        bindings: {const SingleActivator(LogicalKeyboardKey.arrowUp): () {}},
                        child: subtitleItemWidget,
                      )
                    : subtitleItemWidget;
              },
            ),
          )
        : const Focus(autofocus: true, child: SizedBox.shrink());
  }
}
