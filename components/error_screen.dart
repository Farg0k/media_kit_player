import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../generated/l10n.dart';
import '../bloc/media_kit_player_bloc.dart';

class ErrorScreen extends StatelessWidget {
  final String isError;
  const ErrorScreen({super.key, required this.isError});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
      buildWhen: (oldState, newState) => oldState.playerPanel != newState.playerPanel,
      builder: (context, state) {
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowUp): () => _arrowFunction(context: context, action: 1),
            const SingleActivator(LogicalKeyboardKey.arrowDown): () => _arrowFunction(context: context, action: -1),
            const SingleActivator(LogicalKeyboardKey.contextMenu): () =>
                _openPanel(context: context, state: state, playerPanel: PlayerPanel.setup),
            const SingleActivator(LogicalKeyboardKey.keyQ): () =>
                _openPanel(context: context, state: state, playerPanel: PlayerPanel.setup),
            const SingleActivator(LogicalKeyboardKey.mediaStop): () => Navigator.pop(context),
          },
          child: Focus(
            autofocus: true,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    S.of(context).error,
                    style: const TextStyle(color: Colors.red),
                  ),
                  Text(isError),
                  SizedBox(
                    width: 250,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.0, end: 1),
                      duration: const Duration(milliseconds: 2000),
                      builder: (context, value, _) {
                        if (value == 1) {
                          WidgetsBinding.instance.addPostFrameCallback((_) => _onFinished(context: context));
                        }
                        return LinearProgressIndicator(value: value);
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onFinished({required BuildContext context}) {
    final playIndex = context.read<MediaKitPlayerBloc>().state.playIndex;
    final playItems = context.read<MediaKitPlayerBloc>().state.playItems;
    final repeat = context.read<MediaKitPlayerBloc>().state.repeat;
    if (playIndex < playItems.length - 1) {
      context.read<MediaKitPlayerBloc>().add(SetPlayIndex(playIndex: playIndex + 1, debounce: true));
    } else {
      if (repeat == Repeat.all) {
        context.read<MediaKitPlayerBloc>().add(const SetPlayIndex(playIndex: 0, debounce: true));
      } else {
        Navigator.pop(context);
      }
    }
  }

  void _openPanel(
          {required BuildContext context, required MediaKitPlayerState state, required PlayerPanel playerPanel}) =>
      context
          .read<MediaKitPlayerBloc>()
          .add(SetActivePanel(playerPanel: state.playerPanel == playerPanel ? PlayerPanel.none : playerPanel));

  void _arrowFunction({required BuildContext context, required int action}) {
    final bloc = context.read<MediaKitPlayerBloc>();
    final playIndex = bloc.state.playIndex + action;
    if (playIndex < bloc.playItems.length && playIndex >= 0) {
      bloc.add(SetPlayIndex(playIndex: playIndex, debounce: true));
    }
  }
}
