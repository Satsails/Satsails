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

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Image Section
            Expanded(
              flex: 1,
              child: Image.asset(
                'lib/assets/satsails_start_screen.png', // Using the full background image
                fit: BoxFit.cover, // Ensures the image covers the area, edge-to-edge
                width: double.infinity, // Ensures it takes the full width
              ),
            ),

            // Content Section (Text and Buttons)
            Expanded(
              flex: 1,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    children: [
                      // Text Block
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 32.h), // Adds space from the top
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 36.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                                height: 1.2,
                              ),
                              children: [
                                TextSpan(text: 'Become sovereign\nwith '.i18n),
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
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              'The wallet that guarantees sovereignty and the freedom to disconnect from the system'
                                  .i18n,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(), // Pushes the buttons and legal text to the bottom

                      // Buttons and Legal Text Group
                      Column(
                        children: [
                          CustomButton(
                            text: 'Create wallet'.i18n,
                            onPressed: () => context.push('/set_pin'),
                            primaryColor: primaryOrange,
                            secondaryColor:
                            Color.lerp(primaryOrange, Colors.black, 0.2)!,
                            textColor: Colors.black,
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            height: 56.h,
                            child: OutlinedButton(
                              onPressed: () => context.push('/recover_wallet'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                    color: Colors.white.withOpacity(0.3)),
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
                            padding: EdgeInsets.fromLTRB(8.w, 24.h, 8.w, 16.h), // Adjusted spacing
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.white38,
                                  fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                      'By continuing, you agree to our '.i18n),
                                  const TextSpan(text: '\n'),
                                  TextSpan(
                                    text: 'Terms of Use and Privacy Policy'.i18n,
                                    style: const TextStyle(
                                        color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

