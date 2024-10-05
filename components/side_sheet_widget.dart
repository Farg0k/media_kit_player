import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:side_sheet/side_sheet.dart';

import '../../../app_theme/app_theme.dart';
import '../bloc/media_kit_player_bloc.dart';

class SideSheetWidget {
  SideSheetWidget();
  static void openSideSheet({
    required BuildContext context,
    required Widget body,
  }) {
    final bloc = context.read<MediaKitPlayerBloc>();
    if (bloc.state.sideSheetOpen == false) {
      bloc.add(const SetSideSheetState(isOpen: true));
      SideSheet.right(
        body: body,
        width: MediaQuery.of(context).size.width * 0.3,
        context: context,
        sheetColor: AppTheme.backgroundColor,
      ).then((value) {
        bloc.add(const SetSideSheetState(isOpen: false));
      });
    }
  }
}
