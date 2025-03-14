import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import './components/logo.dart'; // Assuming this is your logo widget
import 'package:Satsails/translations/translations.dart'; // For translations

class Start extends ConsumerStatefulWidget {
  const Start({super.key});

  @override
  _StartState createState() => _StartState();
}

class _StartState extends ConsumerState<Start> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoOffset;
  late Animation<double> _textOpacity;
  late Animation<Offset> _buttonsOffset;
  late Animation<double> _buttonsOpacity;

  @override
  void initState() {
    super.initState();

    // Initialize AnimationController with 1.5-second duration
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo animations: fade, scale, and slide up
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );
    _logoOffset = Tween<Offset>(
      begin: const Offset(0, 0.1), // 10% below
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    // Text animation: fade in
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    // Buttons animations: fade and slide up
    _buttonsOffset = Tween<Offset>(
      begin: const Offset(0, 1), // Start below the screen
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack),
      ),
    );
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start the animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Gradient shader for the title text
  Shader createGradientShader(Rect bounds) {
    return const LinearGradient(
      colors: [Colors.redAccent, Colors.orangeAccent],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bounds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.grey[900]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Logo with fade, scale, and slide animations
              FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: SlideTransition(
                    position: _logoOffset,
                    child: const InitialLogo(), // Your logo widget
                  ),
                ),
              ),
              // Text with fade animation
              FadeTransition(
                opacity: _textOpacity,
                child: Padding(
                  padding: EdgeInsets.only(top: 16.sp, left: 16.sp, right: 16.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Satsails',
                        style: TextStyle(
                          foreground: Paint()..shader = createGradientShader(Rect.fromLTWH(0.0, 0.0, 0.6.sw, 0.1.sh)),
                          fontSize: 0.14.sw,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Become sovereign and freely opt out of the system.'.i18n,
                        style: TextStyle(
                          fontSize: 27.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Buttons with fade and slide animations
              SlideTransition(
                position: _buttonsOffset,
                child: FadeTransition(
                  opacity: _buttonsOpacity,
                  child: Padding(
                    padding: const EdgeInsets.all(13.0),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Create wallet'.i18n,
                          onPressed: () => context.push('/set_pin'),
                          primaryColor: Colors.orange,
                          secondaryColor: Colors.orange,
                          textColor: Colors.black,
                        ),
                        const SizedBox(height: 5),
                        CustomButton(
                          text: 'Recover wallet'.i18n,
                          onPressed: () => context.push('/recover_wallet'),
                          primaryColor: Colors.white24,
                          secondaryColor: Colors.white24,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}