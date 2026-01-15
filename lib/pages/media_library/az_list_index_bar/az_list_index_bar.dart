/*
 * @Author: LinXunFeng linxunfeng@yeah.net
 * @Repo: https://github.com/fluttercandies/flutter_scrollview_observer
 * @Date: 2023-10-28 11:35:03
 */
import 'package:flutter/material.dart';
import 'package:scrollview_observer/scrollview_observer.dart';

class AzListIndexBar extends StatefulWidget {
  final GlobalKey parentKey;

  final List<String> symbols;

  final void Function(int index, Offset cursorOffset)? onSelectionUpdate;

  final void Function()? onSelectionEnd;

  const AzListIndexBar({
    super.key,
    required this.parentKey,
    required this.symbols,
    this.onSelectionUpdate,
    this.onSelectionEnd,
  });

  @override
  State<AzListIndexBar> createState() => _AzListIndexBarState();
}

class _AzListIndexBarState extends State<AzListIndexBar> {
  ListObserverController observerController = ListObserverController();

  double observeOffset = 0;

  final ValueNotifier<int> selectedIndex = ValueNotifier(-1);

  Widget _buildListView() {
    return ValueListenableBuilder<int>(
      valueListenable: selectedIndex,
      builder: (BuildContext context, int value, Widget? child) {
        final bodySmall = Theme.of(context).textTheme.bodySmall;

        final primary = Theme.of(context).colorScheme.primary;

        return ListView.separated(
          separatorBuilder: (context, index) => SizedBox(height: 6),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final isSelected = value == index;

            Widget resultWidget = Text(
              widget.symbols[index],
              style: bodySmall?.copyWith(
                fontSize: 8,
                color: isSelected ? Colors.white : null,
              ),
            );

            resultWidget = Container(
              width: 12,
              height: 12,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? primary : Colors.transparent,
              ),
              child: resultWidget,
            );

            resultWidget = Align(
              alignment: Alignment.centerLeft,
              child: resultWidget,
            );

            return resultWidget;
          },
          itemCount: widget.symbols.length,
        );
      },
    );
  }

  _onGestureHandler(dynamic details) async {
    if (details is! DragUpdateDetails && details is! DragDownDetails) return;

    observeOffset = details.localPosition.dy;

    final result = await observerController.dispatchOnceObserve(
      isDependObserveCallback: false,
    );

    final observeResult = result.observeResult;

    // Nothing has changed.
    if (observeResult == null) return;

    final firstChildModel = observeResult.firstChild;
    if (firstChildModel == null) return;
    final firstChildIndex = firstChildModel.index;
    selectedIndex.value = firstChildIndex;

    // Calculate cursor offset.
    final firstChildRenderObj = firstChildModel.renderObject;

    final firstChildRenderObjOffset = firstChildRenderObj.localToGlobal(
      Offset.zero,
      ancestor: widget.parentKey.currentContext?.findRenderObject(),
    );

    final cursorOffset = Offset(
      firstChildRenderObjOffset.dx,
      firstChildRenderObjOffset.dy + firstChildModel.size.width * 0.5,
    );

    widget.onSelectionUpdate?.call(firstChildIndex, cursorOffset);
  }

  void _onGestureEnd([_]) {
    selectedIndex.value = -1;
    widget.onSelectionEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = ListViewObserver(
      controller: observerController,
      dynamicLeadingOffset: () => observeOffset,
      child: _buildListView(),
    );

    resultWidget = GestureDetector(
      onVerticalDragUpdate: _onGestureHandler,
      onVerticalDragDown: _onGestureHandler,
      onVerticalDragCancel: _onGestureEnd,
      onVerticalDragEnd: _onGestureEnd,
      child: resultWidget,
    );

    return resultWidget;
  }
}
