import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

const double _kScrollbarMinLength = 36.0;
const double _kScrollbarMinOverscrollLength = 8.0;
const Duration _kScrollbarFadeDuration = Duration(milliseconds: 250);

// Extracted from iOS 13.1 beta using Debug View Hierarchy.
const Color _kScrollbarColor = CupertinoDynamicColor.withBrightness(
  color: Color(0x59000000),
  darkColor: Color(0x80FFFFFF),
);
const double _kScrollbarThickness = 7;
const Radius _kScrollbarRadius = Radius.circular(1.5);
const Radius _kScrollbarRadiusDragging = Radius.circular(4.0);

// This is the amount of space from the top of a vertical scrollbar to the
// top edge of the scrollable, measured when the vertical scrollbar overscrolls
// to the top.
// TODO(LongCatIsLooong): fix https://github.com/flutter/flutter/issues/32175
const double _kScrollbarMainAxisMargin = 3.0;
const double _kScrollbarCrossAxisMargin = 3.0;

class CustomScrollbar extends StatefulWidget {
  const CustomScrollbar({
    Key key,
    this.controller,
    @required this.child,
  }) : super(key: key);

  final Widget child;

  final ScrollController controller;

  @override
  _CustomScrollbarState createState() => _CustomScrollbarState();
}

class _CustomScrollbarState extends State<CustomScrollbar>
    with TickerProviderStateMixin {
  final GlobalKey _customPaintKey = GlobalKey();
  ScrollbarPainter _painter;

  double _dragScrollbarPositionY;
  Drag _drag;

  double get _thickness {
    return _kScrollbarThickness;
  }

  Radius get _radius {
    return Radius.lerp(_kScrollbarRadius, _kScrollbarRadiusDragging, 1);
  }

  ScrollController _currentController;

  ScrollController get _controller =>
      widget.controller ?? PrimaryScrollController.of(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_painter == null) {
      _painter = _buildScrollbarPainter(context);
    } else {
      _painter
        ..textDirection = Directionality.of(context)
        ..color = CupertinoDynamicColor.resolve(_kScrollbarColor, context)
        ..padding = MediaQuery.of(context).padding;
    }
  }

  /// Returns a [ScrollbarPainter] visually styled like the iOS scrollbar.
  ScrollbarPainter _buildScrollbarPainter(BuildContext context) {
    return ScrollbarPainter(
      color: CupertinoDynamicColor.resolve(_kScrollbarColor, context),
      textDirection: Directionality.of(context),
      thickness: _thickness,
      mainAxisMargin: _kScrollbarMainAxisMargin,
      crossAxisMargin: _kScrollbarCrossAxisMargin,
      radius: _radius,
      padding: MediaQuery.of(context).padding,
      minLength: _kScrollbarMinLength,
      minOverscrollLength: _kScrollbarMinOverscrollLength,
      fadeoutOpacityAnimation: const AlwaysStoppedAnimation(1.0),
    );
  }

  // Handle a gesture that drags the scrollbar by the given amount.
  void _dragScrollbar(double primaryDelta) {
    assert(_currentController != null);

    // Convert primaryDelta, the amount that the scrollbar moved since the last
    // time _dragScrollbar was called, into the coordinate space of the scroll
    // position, and create/update the drag event with that position.
    final double scrollOffsetLocal = _painter.getTrackToScroll(primaryDelta);
    final double scrollOffsetGlobal =
        scrollOffsetLocal + _currentController.position.pixels;

    if (_drag == null) {
      _drag = _currentController.position.drag(
        DragStartDetails(
          globalPosition: Offset(0.0, scrollOffsetGlobal),
        ),
        () {},
      );
    } else {
      _drag.update(DragUpdateDetails(
        globalPosition: Offset(0.0, scrollOffsetGlobal),
        delta: Offset(0.0, -scrollOffsetLocal),
        primaryDelta: -scrollOffsetLocal,
      ));
    }
  }

  bool _checkVertical() {
    try {
      return _currentController.position.axis == Axis.vertical;
    } catch (_) {
      // Ignore the gesture if we cannot determine the direction.
      return false;
    }
  }

  double _pressStartY = 0.0;

  // Long press event callbacks handle the gesture where the user long presses
  // on the scrollbar thumb and then drags the scrollbar without releasing.
  void _handleLongPressStart(LongPressStartDetails details) {
    _currentController = _controller;
    if (!_checkVertical()) {
      return;
    }
    _pressStartY = details.localPosition.dy;
    _dragScrollbar(details.localPosition.dy);
    _dragScrollbarPositionY = details.localPosition.dy;
  }

  void _handleLongPress() {
    if (!_checkVertical()) {
      return;
    }
  }

  void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (!_checkVertical()) {
      return;
    }
    _dragScrollbar(details.localPosition.dy - _dragScrollbarPositionY);
    _dragScrollbarPositionY = details.localPosition.dy;
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    if (!_checkVertical()) {
      return;
    }
    _handleDragScrollEnd(details.velocity.pixelsPerSecond.dy);
    if (details.velocity.pixelsPerSecond.dy.abs() < 10 &&
        (details.localPosition.dy - _pressStartY).abs() > 0) {
      HapticFeedback.mediumImpact();
    }
    _currentController = null;
  }

  void _handleDragScrollEnd(double trackVelocityY) {
    _dragScrollbarPositionY = null;
    final double scrollVelocityY = _painter.getTrackToScroll(trackVelocityY);
    _drag?.end(DragEndDetails(
      primaryVelocity: -scrollVelocityY,
      velocity: Velocity(
        pixelsPerSecond: Offset(
          0.0,
          -scrollVelocityY,
        ),
      ),
    ));
    _drag = null;
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    final ScrollMetrics metrics = notification.metrics;
    if (metrics.maxScrollExtent <= metrics.minScrollExtent) {
      return false;
    }

    if (notification is ScrollUpdateNotification ||
        notification is OverscrollNotification) {
      // Any movements always makes the scrollbar start showing up.
      _painter.update(notification.metrics, notification.metrics.axisDirection);
    } else if (notification is ScrollEndNotification) {
      // On iOS, the scrollbar can only go away once the user lifted the finger.
      if (_dragScrollbarPositionY == null) {}
    }
    return false;
  }

  // Get the GestureRecognizerFactories used to detect gestures on the scrollbar
  // thumb.
  Map<Type, GestureRecognizerFactory> get _gestures {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};

    gestures[_ThumbPressGestureRecognizer] =
        GestureRecognizerFactoryWithHandlers<_ThumbPressGestureRecognizer>(
      () => _ThumbPressGestureRecognizer(
        debugOwner: this,
        customPaintKey: _customPaintKey,
      ),
      (_ThumbPressGestureRecognizer instance) {
        instance
          ..onLongPressStart = _handleLongPressStart
          ..onLongPress = _handleLongPress
          ..onLongPressMoveUpdate = _handleLongPressMoveUpdate
          ..onLongPressEnd = _handleLongPressEnd;
      },
    );

    return gestures;
  }

  @override
  void dispose() {
    _painter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: RepaintBoundary(
        child: RawGestureDetector(
          gestures: _gestures,
          child: CustomPaint(
            key: _customPaintKey,
            foregroundPainter: _painter,
            child: RepaintBoundary(child: widget.child),
          ),
        ),
      ),
    );
  }
}

// A longpress gesture detector that only responds to events on the scrollbar's
// thumb and ignores everything else.
class _ThumbPressGestureRecognizer extends LongPressGestureRecognizer {
  _ThumbPressGestureRecognizer({
    double postAcceptSlopTolerance,
    PointerDeviceKind kind,
    Object debugOwner,
    GlobalKey customPaintKey,
  })  : _customPaintKey = customPaintKey,
        super(
          postAcceptSlopTolerance: postAcceptSlopTolerance,
          kind: kind,
          debugOwner: debugOwner,
          duration: const Duration(milliseconds: 1),
        );

  final GlobalKey _customPaintKey;

  @override
  bool isPointerAllowed(PointerDownEvent event) {
    if (!_hitTestInteractive(_customPaintKey, event.position)) {
      return false;
    }
    return super.isPointerAllowed(event);
  }
}

// foregroundPainter also hit tests its children by default, but the
// scrollbar should only respond to a gesture directly on its thumb, so
// manually check for a hit on the thumb here.
bool _hitTestInteractive(GlobalKey customPaintKey, Offset offset) {
  if (customPaintKey.currentContext == null) {
    return false;
  }
  final CustomPaint customPaint =
      customPaintKey.currentContext.widget as CustomPaint;
  final ScrollbarPainter painter =
      customPaint.foregroundPainter as ScrollbarPainter;
  final RenderBox renderBox =
      customPaintKey.currentContext.findRenderObject() as RenderBox;
  final Offset localOffset = renderBox.globalToLocal(offset);
  return painter.hitTestInteractive(localOffset);
}
