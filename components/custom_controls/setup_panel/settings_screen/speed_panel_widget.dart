import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../const/player_const.dart';
import '../../../../bloc/media_kit_player_bloc.dart';

class SpeedPanelWidget extends StatefulWidget {
  const SpeedPanelWidget({
    super.key,
    required this.videoState, required this.bloc,
  });

  final VideoState videoState;
  final MediaKitPlayerBloc bloc;
  @override
  State<SpeedPanelWidget> createState() => _SpeedPanelWidgetState();
}

class _SpeedPanelWidgetState extends State<SpeedPanelWidget> {
  @override
  Widget build(BuildContext context) {
    final currentSpeed = widget.videoState.widget.controller.player.state.rate;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          leading: const Icon(Icons.speed),
          title: Text(S.of(context).speed),
          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
        ),
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowLeft): _returnToMenu,
            const SingleActivator(LogicalKeyboardKey.arrowRight): _returnToMenu,
            const SingleActivator(LogicalKeyboardKey.contextMenu):  _returnToMenu,
            const SingleActivator(LogicalKeyboardKey.keyQ):  _returnToMenu,
          },
          child: ListView(
            shrinkWrap: true,
            children: PlayerConst.speedList
                .map(
                  (e) => Material(
                    color: Colors.transparent,
                    child: ListTile(
                      selected: e == currentSpeed,
                      autofocus: e == currentSpeed,
                      focusColor: AppTheme.seedColor,
                      title: Text('${e}x'),
                      onTap: () async {
                        await widget.videoState.widget.controller.player.setRate(e);
                        setState(() {});
                      },
                      titleTextStyle: Theme.of(context).textTheme.titleLarge,
                      leading: e == currentSpeed ? const Icon(Icons.check) : null,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
  void _returnToMenu() {
    Navigator.pop(context);
    widget.bloc.add(const SetActivePanel(playerPanel: PlayerPanel.setup));
  }
}
