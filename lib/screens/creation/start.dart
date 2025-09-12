import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/localizations.dart';

class Start extends ConsumerStatefulWidget {
  const Start({super.key});

  @override
  _StartState createState() => _StartState();
}

class _StartState extends ConsumerState<Start> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Fade in the UI when the screen loads
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Define the primary orange color for consistency
    const Color primaryOrange = Color(0xFFF7931A);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Top half of the screen is the image, edge-to-edge
            Image.asset(
              'lib/assets/satsails_start_screen.png',
              width: double.infinity,
              height: screenHeight / 2,
              fit: BoxFit.cover,
            ),
            // Bottom half of the screen for content
            Expanded(
              child: SafeArea(
                top: false, // Only apply safe area to bottom, left, and right
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      RichText(
                        textAlign: TextAlign.center, // Ensure text is centered
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold, // Make the entire headline bold
                            color: Colors.white,
                            fontFamily:
                            Theme.of(context).textTheme.bodyLarge?.fontFamily,
                          ),
                          children: [
                            TextSpan(text: 'Be sovereign with '.i18n),
                            TextSpan(
                              text: 'Satsails',
                              style: TextStyle(
                                color: primaryOrange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'The wallet that guarantees sovereignty and the freedom to disconnect from the system'
                            .i18n,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const Spacer(flex: 3),
                      CustomButton(
                        text: 'Create wallet'.i18n,
                        onPressed: () => context.push('/set_pin'),
                        primaryColor: primaryOrange,
                        secondaryColor:
                        Color.lerp(primaryOrange, Colors.black, 0.2)!,
                        textColor: Colors.black,
                      ),
                      SizedBox(height: 16.h),
                      // Using an OutlinedButton for the secondary action to easily achieve the bordered look
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: OutlinedButton(
                          onPressed: () => context.push('/recover_wallet'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side:
                            BorderSide(color: Colors.white.withOpacity(0.3)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            'Recover wallet'.i18n,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(8.w, 16.h, 8.w, 8.h),
                        child: Text(
                          'By continuing, you agree to our Terms of Use and Privacy Policy'
                              .i18n,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white38,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

