import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../const/player_const.dart';
import '../../../../bloc/media_kit_player_bloc.dart';

class ZoomPanelWidget extends StatelessWidget {
  const ZoomPanelWidget({
    super.key,
    required this.videoState,
    required this.bloc,
  });

  final VideoState videoState;
  final MediaKitPlayerBloc bloc;

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ListTile(
          leading: const Icon(Icons.zoom_in),
          title: Text(S.of(context).zoom),
          titleTextStyle: Theme.of(context).textTheme.headlineMedium,
        ),
        CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _returnToMenu(context: context),
            const SingleActivator(LogicalKeyboardKey.arrowRight): () => _returnToMenu(context: context),
            const SingleActivator(LogicalKeyboardKey.contextMenu): () => _returnToMenu(context: context),
            const SingleActivator(LogicalKeyboardKey.keyQ): () => _returnToMenu(context: context),
          },
          child: BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
            bloc: bloc,
            buildWhen: (oldState, newState) => oldState.boxFit != newState.boxFit,
            builder: (context, state) {
              return ListView(
                shrinkWrap: true,
                children: PlayerConst.zoom.entries
                    .map(
                      (e) => Material(
                        color: Colors.transparent,
                        child: ListTile(
                          selected: e.key == state.boxFit,
                          autofocus: e.key == state.boxFit,
                          focusColor: AppTheme.seedColor,
                          title: Text(e.value),
                          onTap: () async {
                            bloc.add(SetBoxFit(value: e.key));
                          },
                          titleTextStyle: Theme.of(context).textTheme.titleLarge,
                          leading: e.key == state.boxFit ? const Icon(Icons.check) : null,
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  void _returnToMenu({required BuildContext context}) {
    Navigator.pop(context);
    bloc.add(const SetActivePanel(playerPanel: PlayerPanel.setup));
  }
}
