import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/media_kit_player_bloc.dart';

class PlaceholderWidget extends StatelessWidget {
  final String? placeholderImg;
  final String? text;
  const PlaceholderWidget({
    super.key,
    this.placeholderImg,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowUp): () => _arrowFunction(context: context, action: 1),
        const SingleActivator(LogicalKeyboardKey.arrowDown): () => _arrowFunction(context: context, action: -1),
        const SingleActivator(LogicalKeyboardKey.contextMenu): () =>
            _openPanel(context: context, playerPanel: PlayerPanel.setup),
        const SingleActivator(LogicalKeyboardKey.keyQ): () =>
            _openPanel(context: context, playerPanel: PlayerPanel.setup),
        const SingleActivator(LogicalKeyboardKey.mediaStop): () => Navigator.pop(context),
      },
      child: Focus(
        autofocus: true,
        child: Stack(
          children: [
            placeholderImg != null
                ? CachedNetworkImage(
                    imageUrl: placeholderImg!,
                    width: 1920,
                    height: 1080,
                    placeholder: (context, url) => const DefaultPlaceholderWidget(),
                    errorWidget: (context, url, error) => const DefaultPlaceholderWidget(),
                    fit: BoxFit.cover,
                  )
                : const DefaultPlaceholderWidget(),
            const Positioned(
              bottom: 15,
              left: 200,
              right: 200,
              child: LinearProgressIndicator(),
            ),
            Positioned(
                bottom: 25,
                left: 10,
                right: 10,
                child: Text(
                  text ?? '',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                )),
          ],
        ),
      ),
    );
  }

  void _openPanel({required BuildContext context, required PlayerPanel playerPanel}) =>
      context.read<MediaKitPlayerBloc>().add(SetActivePanel(
          playerPanel:
              context.read<MediaKitPlayerBloc>().state.playerPanel == playerPanel ? PlayerPanel.none : playerPanel));

  void _arrowFunction({required BuildContext context, required int action}) {
    final bloc = context.read<MediaKitPlayerBloc>();
    final playIndex = bloc.state.playIndex + action;
    if (playIndex < bloc.playItems.length && playIndex >= 0) {
      bloc.add(SetPlayIndex(playIndex: playIndex, debounce: true));
    }
  }
}

class DefaultPlaceholderWidget extends StatelessWidget {
  const DefaultPlaceholderWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E0E0E),
      child: Center(
        child: SizedBox.square(
          dimension: 250,
          child: Image.asset('assets/images/launcher.png'),
        ),
      ),
    );
  }
}
