import '../../../../../utils/string_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../../../generated/l10n.dart';
import '../../../../../const/player_const.dart';
import '../../../../bloc/media_kit_player_bloc.dart';


class SleepTimerWidget extends StatelessWidget {
  final MediaKitPlayerBloc bloc;
  const SleepTimerWidget({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BlocBuilder<MediaKitPlayerBloc, MediaKitPlayerState>(
          bloc: bloc,
          buildWhen: (oldState, newState) =>
              oldState.sleepTime != newState.sleepTime || oldState.sleepAfter != newState.sleepAfter,
          builder: (context, state) {
            return ListTile(
                leading: const Icon(Icons.timelapse),
                title: Text(S.of(context).sleepTimer),
                titleTextStyle: Theme.of(context).textTheme.headlineMedium,
                subtitle: state.sleepTime != Duration.zero
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.access_time_filled_outlined, color: Colors.grey),
                          const SizedBox(width: 5),
                          Text(
                            state.sleepTime.toString().durationClear(),
                            style: TextStyle(
                              color: state.sleepTime < const Duration(minutes: 4)
                                  ? Colors.orange
                                  : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ],
                      )
                    : const SizedBox.shrink());
          },
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
            buildWhen: (oldState, newState) =>
                oldState.sleepTime != newState.sleepTime || oldState.sleepAfter != newState.sleepAfter,
            builder: (context, state) {
              List<Duration> listDuration = PlayerConst.sleepTimer.values.toList();
              final selectedIndex = _getSelectedIndex(state: state, listDuration: listDuration);
              return ListView(
                shrinkWrap: true,
                children: PlayerConst.sleepTimer.entries.indexed
                    .map(
                      (e) => Material(
                        color: Colors.transparent,
                        child: ListTile(
                          selected: e.$1 == selectedIndex,
                          autofocus: e.$1 == selectedIndex,
                          focusColor: AppTheme.seedColor,
                          title: Text(e.$2.key),
                          onTap: () async {
                            final sleepTimerEvent = e.$1 == 0
                                ? const SetSleepTimer()
                                : e.$1 == 1
                                    ? const SetSleepTimer(sleepAfter: true)
                                    : SetSleepTimer(sleepTime: listDuration[e.$1]);
                            bloc.add(sleepTimerEvent);
                            Navigator.of(context).pop();
                          },
                          titleTextStyle: Theme.of(context).textTheme.titleLarge,
                          leading: e.$1 == selectedIndex ? const Icon(Icons.check) : null,
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

  int _getSelectedIndex({required MediaKitPlayerState state, required List<Duration> listDuration}) {
    if (state.sleepTime != Duration.zero) {
      for (var e in listDuration.indexed) {
        if (e.$2 >= state.sleepTime) {
          return e.$1;
        }
      }
      return 2;
    }
    if (state.sleepAfter != false) {
      return 1;
    }
    return 0;
  }

  void _returnToMenu({required BuildContext context}) {
    Navigator.pop(context);
    bloc.add(const SetActivePanel(playerPanel: PlayerPanel.setup));
  }
}
