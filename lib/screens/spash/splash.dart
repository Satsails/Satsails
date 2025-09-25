import 'package:Satsails/providers/auth_provider.dart';
import 'package:Satsails/screens/creation/components/logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    // A slight delay to ensure the splash screen is visible for a moment.
    await Future.delayed(const Duration(seconds: 2));

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Logo(
          size: 200.sp, // Made the logo larger for the splash screen
          opacity: 0.8,
          animated: true,
        ),
      ),
    );
  }
}
