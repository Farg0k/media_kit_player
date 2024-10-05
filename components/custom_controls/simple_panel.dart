
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../app_theme/app_theme.dart';
import 'time_line_panel.dart';

class SimplePanel extends StatelessWidget {
  final VideoState videoState;
  const SimplePanel({super.key, required this.videoState});

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            child: Container(
              constraints: BoxConstraints(
                minHeight: 60,
                maxWidth: MediaQuery.of(context).size.width,
              ),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppTheme.backgroundColor),
              child: TimeLinePanel(videoState: videoState),
            ),
          )
        ],
      ),
    );
  }
}