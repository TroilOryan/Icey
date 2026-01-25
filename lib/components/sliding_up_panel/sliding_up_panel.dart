/*
Name: Akshath Jain
Date: 3/18/2019 - 4/2/2020
Purpose: Defines the sliding_up_panel widget
Copyright: © 2020, Akshath Jain. All rights reserved.
Licensing: More information can be found here: https://github.com/akshathjain/sliding_up_panel/blob/master/LICENSE
*/

import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/physics.dart';

enum PanelState { OPEN, CLOSED }

const double minFlingVelocity = 365.0;
const double kSnap = 8;

class SlidingUpPanel extends StatefulWidget {
  final Color? color;

  /// The Widget that slides into view. When the
  /// panel is collapsed and if [collapsed] is null,
  /// then top portion of this Widget will be displayed;
  /// otherwise, [collapsed] will be displayed overtop
  /// [panel] will be used.
  final Widget panel;

  /// The Widget displayed overtop the [panel] when collapsed.
  /// This fades out as the panel is opened.
  final Widget collapsed;

  /// The Widget that lies underneath the sliding panel.
  /// This Widget automatically sizes itself
  /// to fill the screen.
  final Widget body;

  /// The height of the sliding panel when fully collapsed.
  final double minHeight;

  /// The height of the sliding panel when fully open.
  final double maxHeight;

  /// A point between [minHeight] and [maxHeight] that the panel snaps to
  /// while animating. A fast swipe on the panel will disregard this point
  /// and go directly to the open/close position. This value is represented as a
  /// percentage of the total animation distance ([maxHeight] - [minHeight]),
  /// so it must be between 0.0 and 1.0, exclusive.
  final double? snapPoint;

  /// A list of shadows cast behind the sliding panel sheet.
  final List<BoxShadow>? boxShadow;

  /// Set to false to disable the panel from snapping open or closed.
  final bool panelSnapping;

  /// If non-null, this can be used to control the state of the panel.
  final PanelController? controller;

  /// If non-null, this callback
  /// is called as the panel slides around with the
  /// current position of the panel. The position is a double
  /// between 0.0 and 1.0 where 0.0 is fully collapsed and 1.0 is fully open.
  final void Function(double position)? onPanelSlide;

  /// If non-null, this callback is called when the
  /// panel is fully opened
  final VoidCallback? onPanelOpened;

  /// If non-null, this callback is called when the panel
  /// is fully collapsed.
  final VoidCallback? onPanelClosed;

  /// Allows toggling of the draggability of the SlidingUpPanel.
  /// Set this to false to prevent the user from being able to drag
  /// the panel up and down. Defaults to true.
  final bool isDraggable;

  /// The default state of the panel; either PanelState.OPEN or PanelState.CLOSED.
  /// This value defaults to PanelState.CLOSED which indicates that the panel is
  /// in the closed position and must be opened. PanelState.OPEN indicates that
  /// by default the Panel is open and must be swiped closed by the user.
  final PanelState defaultPanelState;

  const SlidingUpPanel({
    super.key,
    this.color,
    required this.panel,
    required this.body,
    required this.collapsed,
    this.minHeight = 100.0,
    this.maxHeight = 500.0,
    this.snapPoint,
    this.boxShadow = const <BoxShadow>[
      BoxShadow(
        blurRadius: 8.0,
        color: Color.fromRGBO(0, 0, 0, 0.08),
        spreadRadius: 6,
      ),
    ],
    this.panelSnapping = true,
    this.controller,
    this.onPanelSlide,
    this.onPanelOpened,
    this.onPanelClosed,
    this.isDraggable = true,
    this.defaultPanelState = PanelState.CLOSED,
  }) : assert(snapPoint == null || 0 < snapPoint && snapPoint < 1.0);

  @override
  SlidingUpPanelState createState() => SlidingUpPanelState();
}

class SlidingUpPanelState extends State<SlidingUpPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;

  late final ScrollController _sc;

  bool _scrollingEnabled = false;

  final ValueNotifier<bool> _panelVisibleListenable = ValueNotifier<bool>(true);

  @override
  void initState() {
    super.initState();

    _ac =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
          value: widget.defaultPanelState == PanelState.CLOSED
              ? 0.0
              : 1.0, //set the default panel state (i.e. set initial value of _ac)
        )..addListener(() {
          if (widget.onPanelSlide != null) widget.onPanelSlide!(_ac.value);

          if (widget.onPanelOpened != null && _ac.value == 1.0) {
            widget.onPanelOpened!();
          }

          if (widget.onPanelClosed != null && _ac.value == 0.0) {
            widget.onPanelClosed!();
          }
        });

    // prevent the panel content from being scrolled only if the widget is
    // draggable and panel scrolling is enabled
    _sc = ScrollController()
      ..addListener(() {
        if (widget.isDraggable && !_scrollingEnabled) _sc.jumpTo(0);
      });

    widget.controller?._addState(this);
  }

  @override
  void dispose() {
    _ac.dispose();
    _sc.dispose();
    super.dispose();
  }

  // returns a gesture detector if panel is used
  // this is because the listener is designed only for use with linking the scrolling of
  // panels and using it for panels that don't want to linked scrolling yields odd results
  Widget _gestureHandler({required Widget child}) {
    if (!widget.isDraggable) {
      return child;
    }

    return GestureDetector(
      onTap: widget.isDraggable != false ? _open : null,
      onVerticalDragUpdate: (DragUpdateDetails dets) =>
          _onGestureSlide(dets.delta.dy),
      onVerticalDragEnd: (DragEndDetails dets) => _onGestureEnd(dets.velocity),
      child: child,
    );

    // return Listener(
    //   onPointerDown: (PointerDownEvent p) =>
    //       _vt.addPosition(p.timeStamp, p.position),
    //   onPointerMove: (PointerMoveEvent p) {
    //     _vt.addPosition(p.timeStamp,
    //         p.position); // add current position for velocity tracking
    //     _onGestureSlide(p.delta.dy);
    //   },
    //   onPointerUp: (PointerUpEvent p) => _onGestureEnd(_vt.getVelocity()),
    //   child: child,
    // );
  }

  // handles the sliding gesture
  void _onGestureSlide(double dy) {
    // only slide the panel if scrolling is not enabled
    if (!_scrollingEnabled) {
      _ac.value -= dy / (widget.maxHeight - widget.minHeight);
    }

    // if the panel is open and the user hasn't scrolled, we need to determine
    // whether to enable scrolling if the user swipes up, or disable closing and
    // begin to close the panel if the user swipes down
    if (_isPanelOpen && _sc.hasClients && _sc.offset <= 0) {
      if (dy < 0) {
        _scrollingEnabled = true;
      } else {
        _scrollingEnabled = false;
      }
    }
  }

  // handles when user stops sliding
  void _onGestureEnd(Velocity v) {
    //let the current animation finish before starting a new one
    if (_ac.isAnimating) return;

    // if scrolling is allowed and the panel is open, we don't want to close
    // the panel if they swipe up on the scrollable
    if (_isPanelOpen && _scrollingEnabled) return;

    //check if the velocity is sufficient to constitute fling to end
    double visualVelocity =
        -v.pixelsPerSecond.dy / (widget.maxHeight - widget.minHeight);

    // get minimum distances to figure out where the panel is at
    double d2Close = _ac.value;
    double d2Open = 1 - _ac.value;
    double d2Snap = ((widget.snapPoint ?? 3) - _ac.value)
        .abs(); // large value if null results in not every being the min
    double minDistance = min(d2Close, min(d2Snap, d2Open));

    // check if velocity is sufficient for a fling
    if (v.pixelsPerSecond.dy.abs() >= minFlingVelocity) {
      // snapPoint exists
      if (widget.panelSnapping && widget.snapPoint != null) {
        if (v.pixelsPerSecond.dy.abs() >= kSnap * minFlingVelocity ||
            minDistance == d2Snap) {
          _ac.fling(velocity: visualVelocity);
        } else {
          _flingPanelToPosition(widget.snapPoint!, visualVelocity);
        }

        // no snap point exists
      } else if (widget.panelSnapping) {
        _ac.fling(velocity: visualVelocity);

        // panel snapping disabled
      } else {
        _ac.animateTo(
          _ac.value + visualVelocity * 0.16,
          duration: const Duration(milliseconds: 100),
          curve: Curves.bounceInOut,
        );
      }

      return;
    }

    // check if the controller is already halfway there
    if (widget.panelSnapping) {
      if (minDistance == d2Close) {
        _close();
      } else if (minDistance == d2Snap) {
        _flingPanelToPosition(widget.snapPoint!, visualVelocity);
      } else {
        _open();
      }
    }
  }

  void _flingPanelToPosition(double targetPos, double velocity) {
    final Simulation simulation = SpringSimulation(
      SpringDescription.withDampingRatio(
        mass: 1.0,
        stiffness: 500.0,
        ratio: 1.0,
      ),
      _ac.value,
      targetPos,
      velocity,
    );

    _ac.animateWith(simulation);
  }

  //---------------------------------
  //PanelController related functions
  //---------------------------------

  //close the panel
  Future<void> _close() {
    return _ac.fling(velocity: -1.0);
  }

  //open the panel
  Future<void> _open() {
    return _ac.fling(velocity: 1.0);
  }

  //hide the panel (completely offscreen)
  Future<void> _hide() {
    return _ac.fling(velocity: -1.0).then((x) {
      _panelVisibleListenable.value = false;
    });
  }

  //show the panel (in collapsed mode)
  Future<void> _show() {
    return _ac.fling(velocity: -1.0).then((x) {
      _panelVisibleListenable.value = true;
    });
  }

  //animate the panel position to value - must
  //be between 0.0 and 1.0
  Future<void> _animatePanelToPosition(
    double value, {
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    assert(0.0 <= value && value <= 1.0);
    return _ac.animateTo(value, duration: duration, curve: curve);
  }

  //animate the panel position to the snap point
  //REQUIRES that widget.snapPoint != null
  Future<void> _animatePanelToSnapPoint({
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    assert(widget.snapPoint != null);
    return _ac.animateTo(widget.snapPoint!, duration: duration, curve: curve);
  }

  //set the panel position to value - must
  //be between 0.0 and 1.0
  set _panelPosition(double value) {
    assert(0.0 <= value && value <= 1.0);
    _ac.value = value;
  }

  //get the current panel position
  //returns the % offset from collapsed state
  //as a decimal between 0.0 and 1.0
  double get _panelPosition => _ac.value;

  //returns whether or not
  //the panel is still animating
  bool get _isPanelAnimating => _ac.isAnimating;

  //returns whether or not the
  //panel is open
  bool get _isPanelOpen => _ac.value == 1.0;

  //returns whether or not the
  //panel is closed
  bool get _isPanelClosed => _ac.value == 0.0;

  //returns whether or not the
  //panel is shown/hidden
  bool get _isPanelShown => _panelVisibleListenable.value;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        //make the back widget take up the entire back side
        RepaintBoundary(
          key: const ValueKey("body"),
          child: SizedBox(height: height, width: width, child: widget.body),
        ),

        //the actual sliding part
        RepaintBoundary(
          child: ValueListenableBuilder(
            valueListenable: _panelVisibleListenable,
            builder: (context, panelVisible, child) {
              return panelVisible
                  ? _gestureHandler(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: widget.boxShadow,
                          color: widget.color,
                        ),
                        child: ValueListenableBuilder(
                          valueListenable: _ac,
                          builder: (context, value, child) => Builder(
                            builder: (context) {
                              return AnimatedContainer(
                                curve: Curves.easeInOutSine,
                                duration: Duration(
                                  milliseconds: widget.minHeight == 0
                                      ? 500
                                      : value > 0
                                      ? 0
                                      : 500,
                                ),
                                height:
                                    value *
                                        (widget.maxHeight - widget.minHeight) +
                                    widget.minHeight,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 0,
                                      width: width,
                                      child: Stack(
                                        children: [
                                          RepaintBoundary(
                                            key: const ValueKey("panel"),
                                            child: IgnorePointer(
                                              ignoring: value != 1,
                                              child: AnimatedOpacity(
                                                opacity: value < 0.02
                                                    ? value * 50
                                                    : 1,
                                                duration: const Duration(
                                                  milliseconds: 50,
                                                ),
                                                child: SizedBox(
                                                  height: widget.maxHeight,
                                                  child: widget.panel,
                                                ),
                                              ),
                                            ),
                                          ),
                                          RepaintBoundary(
                                            key: const ValueKey("collapsed"),
                                            child: IgnorePointer(
                                              ignoring: value != 0,
                                              child: AnimatedOpacity(
                                                duration: const Duration(
                                                  milliseconds: 50,
                                                ),
                                                opacity: value < 0.02
                                                    ? 1 - value * 50
                                                    : 0,
                                                child: widget.collapsed,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    )
                  : Container();
            },
          ),
        ),
      ],
    );
  }
}

class PanelController {
  SlidingUpPanelState? _panelState;

  void _addState(SlidingUpPanelState panelState) {
    _panelState = panelState;
  }

  /// Determine if the panelController is attached to an instance
  /// of the SlidingUpPanel (this property must return true before any other
  /// functions can be used)
  bool get isAttached => _panelState != null;

  /// Closes the sliding panel to its collapsed state (i.e. to the  minHeight)
  Future<void> close() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._close();
  }

  /// Opens the sliding panel fully
  /// (i.e. to the maxHeight)
  Future<void> open() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._open();
  }

  /// Hides the sliding panel (i.e. is invisible)
  Future<void> hide() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._hide();
  }

  /// Shows the sliding panel in its collapsed state
  /// (i.e. "un-hide" the sliding panel)
  Future<void> show() {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._show();
  }

  /// Animates the panel position to the value.
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToPosition(
    double value, {
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    return _panelState!._animatePanelToPosition(
      value,
      duration: duration,
      curve: curve,
    );
  }

  /// Animates the panel position to the snap point
  /// Requires that the SlidingUpPanel snapPoint property is not null
  /// (optional) duration specifies the time for the animation to complete
  /// (optional) curve specifies the easing behavior of the animation.
  Future<void> animatePanelToSnapPoint({
    Duration? duration,
    Curve curve = Curves.linear,
  }) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(
      _panelState!.widget.snapPoint != null,
      "SlidingUpPanel snapPoint property must not be null",
    );
    return _panelState!._animatePanelToSnapPoint(
      duration: duration,
      curve: curve,
    );
  }

  /// Sets the panel position (without animation).
  /// The value must between 0.0 and 1.0
  /// where 0.0 is fully collapsed and 1.0 is completely open.
  set panelPosition(double value) {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    assert(0.0 <= value && value <= 1.0);
    _panelState!._panelPosition = value;
  }

  /// Gets the current panel position.
  /// Returns the % offset from collapsed state
  /// to the open state
  /// as a decimal between 0.0 and 1.0
  /// where 0.0 is fully collapsed and
  /// 1.0 is full open.
  double get panelPosition {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._panelPosition;
  }

  /// Returns whether or not the panel is
  /// currently animating.
  bool get isPanelAnimating {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelAnimating;
  }

  /// Returns whether or not the
  /// panel is open.
  bool get isPanelOpen {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelOpen;
  }

  /// Returns whether or not the
  /// panel is closed.
  bool get isPanelClosed {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelClosed;
  }

  /// Returns whether or not the
  /// panel is shown/hidden.
  bool get isPanelShown {
    assert(isAttached, "PanelController must be attached to a SlidingUpPanel");
    return _panelState!._isPanelShown;
  }
}
