import 'package:Satsails/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Splash extends ConsumerStatefulWidget {
  const Splash({super.key});

  @override
  ConsumerState<Splash> createState() => _SplashState();
}

class _SplashState extends ConsumerState<Splash> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAppAndRedirect();
    });
  }

  /// Checks for an existing wallet and redirects the user accordingly.
  Future<void> _initializeAppAndRedirect() async {
    final authModel = ref.read(authModelProvider);
    final mnemonic = await authModel.getMnemonic();

    if (!mounted) return;

    if (mnemonic != null && mnemonic.isNotEmpty) {
      context.go('/open_pin');
    } else {
      context.go('/start');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicAnimationSize = screenHeight * 0.05;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'lib/assets/satsails.svg',
            ),
            SizedBox(height: screenHeight * 0.03),
            LoadingAnimationWidget.fourRotatingDots(size: dynamicAnimationSize, color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
