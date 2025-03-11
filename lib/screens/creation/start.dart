import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import './components/logo.dart';

class Start extends ConsumerWidget {
  const Start({super.key});

  Shader createGradientShader(Rect bounds) {
    return const LinearGradient(
      colors: [Colors.redAccent, Colors.orangeAccent],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).createShader(bounds);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const InitialLogo(),
            Padding(
              padding: EdgeInsets.only(top:16.sp, left:16.sp, right:16.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Satsails',
                    style: TextStyle(
                      foreground: Paint()
                        ..shader = createGradientShader(
                          Rect.fromLTWH(0.0, 0.0, 0.6.sw, 0.1.sh),
                        ),
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
            Spacer(),
            Padding(
              padding: const EdgeInsets.all(13.0),
              child: Column(
                children: [
                  CustomButton(
                    text: 'Create wallet'.i18n,
                    onPressed: () {
                      context.push('/set_pin');
                    },
                      primaryColor: Colors.orange,
                      secondaryColor: Colors.orange,
                      textColor: Colors.black,
                  ),
                  SizedBox(height: 5),
                  CustomButton(
                      text: 'Recover wallet'.i18n,
                      onPressed: () {
                        context.push('/recover_wallet');
                      },
                      primaryColor: Colors.white24,
                      secondaryColor: Colors.white24,
                      textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
