import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

const double _kDefaultIndicatorRadius = 10.0;

const Color _kActiveTickColor = CupertinoDynamicColor.withBrightness(
  color: Colors.white,
  darkColor: Colors.white,
);

class MelonActivityIndicator extends StatefulWidget {
  const MelonActivityIndicator({
    Key? key,
    this.animating = true,
    this.color,
    this.radius = _kDefaultIndicatorRadius,
  })  : assert(animating != null),
        assert(radius != null),
        assert(radius > 0.0),
        progress = 1.0,
        super(key: key);

  final bool animating;
  final Color? color;

  final double radius;

  final double progress;

  @override
  _MelonActivityIndicatorState createState() => _MelonActivityIndicatorState();
}

class _MelonActivityIndicatorState extends State<MelonActivityIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (widget.animating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(MelonActivityIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animating != oldWidget.animating) {
      if (widget.animating)
        _controller.repeat();
      else
        _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.radius * 2,
      width: widget.radius * 2,
      child: CustomPaint(
        painter: _MelonActivityIndicatorPainter(
          position: _controller,
          activeColor: widget.color ??
              CupertinoDynamicColor.resolve(_kActiveTickColor, context),
          radius: widget.radius,
          progress: widget.progress,
        ),
      ),
    );
  }
}

const List<int> _kAlphaValues = <int>[
  20,
  47,
  60,
  80,
  100,
  140,
  190,
  255,
];

const int _partiallyRevealedAlpha = 147;

const double _kTwoPI = math.pi * 2.0;

class _MelonActivityIndicatorPainter extends CustomPainter {
  _MelonActivityIndicatorPainter({
    @required this.position,
    @required this.activeColor,
    @required this.radius,
    @required this.progress,
  })  : tickFundamentalRRect = RRect.fromLTRBXY(
          -radius! / _kDefaultIndicatorRadius,
          -radius / 3.0,
          radius / _kDefaultIndicatorRadius,
          -radius,
          radius / _kDefaultIndicatorRadius,
          radius / _kDefaultIndicatorRadius,
        ),
        super(repaint: position);

  final Animation<double>? position;
  final Color? activeColor;
  final double? radius;
  final double? progress;

  final RRect tickFundamentalRRect;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final int tickCount = _kAlphaValues.length;

    canvas.save();
    canvas.translate(size.width / 2.0, size.height / 2.0);

    final int activeTick = (tickCount * position!.value).floor();

    for (int i = 0; i < tickCount * progress!; ++i) {
      final int t = (i - activeTick) % tickCount;
      paint.color = activeColor!.withAlpha(
          progress! < 1 ? _partiallyRevealedAlpha : _kAlphaValues[t]);
      canvas.drawRRect(tickFundamentalRRect, paint);
      canvas.rotate(_kTwoPI / tickCount);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_MelonActivityIndicatorPainter oldPainter) {
    return oldPainter.position != position ||
        oldPainter.activeColor != activeColor ||
        oldPainter.progress != progress;
  }
}
