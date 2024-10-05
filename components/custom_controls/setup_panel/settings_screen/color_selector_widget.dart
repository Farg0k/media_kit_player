import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_carousel/infinite_carousel.dart';

import '../../../../../../app_theme/app_theme.dart';
import '../../../../../const/player_const.dart';

class ColorSelectorWidget extends StatefulWidget {
  final int initialItem;
  final Function(int) saveResult;
  final bool autofocus;
  const ColorSelectorWidget({super.key, required this.initialItem, required this.saveResult, this.autofocus = false});

  @override
  State<ColorSelectorWidget> createState() => _ColorSelectorWidgetState();
}

class _ColorSelectorWidgetState extends State<ColorSelectorWidget> {

  FocusNode focusNode = FocusNode();
  int selectColor = 0;
  bool colorFocus = false;
  late InfiniteScrollController _scrollControllerColor;
  @override
  void initState() {
    _scrollControllerColor = InfiniteScrollController(initialItem: widget.initialItem);
    selectColor = widget.initialItem;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = PlayerConst.colorList.length;
    return SizedBox(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.3,
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _setSelectItem(action: -1, itemCount: itemCount),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => _setSelectItem(action: 1, itemCount: itemCount),
        },
        child: Focus(
          autofocus: widget.autofocus,
          focusNode: focusNode,
          onFocusChange: (focus) => setState(() => colorFocus = focus),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: colorFocus == true ? AppTheme.seedColor : Theme.of(context).dividerColor,
                style: BorderStyle.solid,
                width: 2.0,
              ),
              borderRadius: AppTheme.borderRadius,
            ),
            padding: const EdgeInsets.all(3),
            child: InfiniteCarousel.builder(
              itemCount: PlayerConst.colorList.length,
              itemExtent: 50,
              center: true,
              anchor: 0.0,
              velocityFactor: 0.2,
              onIndexChanged: (index) => setState(() => selectColor = index),
              controller: _scrollControllerColor,
              axisDirection: Axis.horizontal,
              loop: true,
              itemBuilder: (context, itemIndex, realIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: GestureDetector(
                    onTap: () => _scrollControllerColor.jumpToItem(itemIndex),
                    child: Container(
                      decoration: BoxDecoration(
                        color: PlayerConst.colorList[itemIndex],
                        border: Border.all(
                            color: itemIndex == selectColor ? Colors.white : Colors.grey,
                            width: itemIndex == selectColor ? 2 : 1.0),
                        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                      ),
                      height: 20,
                      width: 20,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _setSelectItem({required int action, required int itemCount}) {
    final itemIndex = selectColor + action < 0
        ? itemCount - 1
        : selectColor + action > itemCount - 1
        ? 0
        : selectColor + action;
    widget.saveResult(itemIndex);
    itemIndex == itemCount - 1 || itemIndex == 0
        ? _scrollControllerColor.jumpToItem(itemIndex)
        : _scrollControllerColor.animateToItem(itemIndex);
  }
}
