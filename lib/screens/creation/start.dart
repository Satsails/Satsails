import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import './components/logo.dart';
import 'package:Satsails/translations/translations.dart';

class Start extends ConsumerStatefulWidget {
  const Start({super.key});

  @override
  _StartState createState() => _StartState();
}

class _StartState extends ConsumerState<Start>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoOffset;
  late Animation<double> _textOpacity;
  late Animation<Offset> _buttonsOffset;
  late Animation<double> _buttonsOpacity;

  // The state and logic for checking the wallet have been removed.
  // bool _isCheckingWallet = true; <-- REMOVED

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );
    _logoOffset =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
        );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
    );

    _buttonsOffset =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.6, 1.0, curve: Curves.easeOutBack)),
        );
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _controller.forward();

    // The call to _checkExistingWallet() has been removed.
  }

  // The _checkExistingWallet() method has been completely removed.

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Shader createGradientShader(Rect bounds) {
    return const LinearGradient(
      colors: [Colors.redAccent, Colors.orangeAccent],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bounds);
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = 300.h;

    return SafeArea(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.grey[900]!],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 70.h),
                child: FadeTransition(
                  opacity: _logoOpacity,
                  child: ScaleTransition(
                    scale: _logoScale,
                    child: SlideTransition(
                      position: _logoOffset,
                      child: SizedBox(
                        width: logoSize,
                        height: logoSize,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const InitialLogo(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              FadeTransition(
                opacity: _textOpacity,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Satsails',
                        style: TextStyle(
                          foreground: Paint()
                            ..shader = createGradientShader(
                                Rect.fromLTWH(0.0, 0.0, 0.6.sw, 0.1.sh)),
                          fontSize: 60.sp,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 5,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'Your gateway to financial freedom.'.i18n,
                        style: TextStyle(
                          fontSize: 24.sp,
                          color: Colors.white70,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 3,
                              offset: const Offset(1, 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SlideTransition(
                position: _buttonsOffset,
                child: FadeTransition(
                  opacity: _buttonsOpacity,
                  child: Padding(
                    padding: EdgeInsets.all(20.w),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Create wallet'.i18n,
                          onPressed: () => context.push('/set_pin'),
                          primaryColor: Colors.orange,
                          secondaryColor: Colors.orange,
                          textColor: Colors.black,
                        ),
                        SizedBox(height: 10.h),
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
