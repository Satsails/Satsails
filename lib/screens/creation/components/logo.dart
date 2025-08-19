import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Logo extends StatefulWidget {
  final Color color;
  final double opacity;
  final double? size;
  final bool animated;

  const Logo({
    super.key,
    this.color = Colors.white,
    this.opacity = 1.0,
    this.size,
    this.animated = false, // Animation is off by default.
  });

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> with SingleTickerProviderStateMixin {
  // Controller and Animation are now nullable.
  // They will only be initialized if widget.animated is true.
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();

    // Only set up the animation if the widget is configured to be animated.
    if (widget.animated) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1300),
      )..repeat(reverse: true);

      // Use a CurvedAnimation for a smoother, more natural pulse.
      final curvedAnimation = CurvedAnimation(
        parent: _controller!,
        curve: Curves.easeInOut,
      );

      // Define the animation's value range using a Tween.
      // It will animate from 40% of the original opacity to the full opacity.
      _animation = Tween<double>(
        begin: widget.opacity * 0.4,
        end: widget.opacity,
      ).animate(curvedAnimation);
    }
  }

  @override
  void dispose() {
    // Safely dispose of the controller only if it was created.
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animated) {
      return AnimatedBuilder(
        animation: _animation!,
        builder: (context, child) {
          return SvgPicture.asset(
            'lib/assets/satsails.svg',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              // Use the animation's current value for the opacity.
              widget.color.withOpacity(_animation!.value),
              BlendMode.srcIn,
            ),
          );
        },
      );
    } else {
      return SvgPicture.asset(
        'lib/assets/satsails.svg',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          widget.color.withOpacity(widget.opacity),
          BlendMode.srcIn,
        ),
      );
    }
  }
}
