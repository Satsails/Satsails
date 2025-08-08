import 'dart:async';
import 'dart:ui';
import 'package:Satsails/screens/creation/components/logo.dart';
import 'package:Satsails/screens/shared/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:Satsails/translations/translations.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:video_player/video_player.dart';

class Start extends ConsumerStatefulWidget {
  const Start({super.key});

  @override
  _StartState createState() => _StartState();
}

class _StartState extends ConsumerState<Start> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  VideoPlayerController? _videoController;
  bool _isVideoReady = false;
  // New state to track if the video is currently trying to load.
  bool _isLoadingVideo = true;

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

    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse('https://satsails-assets.nyc3.cdn.digitaloceanspaces.com/Realistic_Astronaut_Rocket_Launch_Video.mp4'),
    );

    try {
      await _videoController!.initialize().timeout(const Duration(seconds: 7));
      if (!mounted) return;

      setState(() {
        _isVideoReady = true;
        _isLoadingVideo = false; // Video loaded successfully, hide spinner
        _videoController!.setLooping(true);
        _videoController!.play();
      });
    } catch (e) {
      // This includes timeouts and other errors like the SSLHandshakeException
      print("Video failed to load, falling back to static background. Error: $e");
      if (!mounted) return;
      setState(() {
        _isVideoReady = false;
        _isLoadingVideo = false; // Video failed, hide spinner
      });
    } finally {
      // Fade in the UI regardless of the video's status
      if (mounted) {
        _fadeController.forward();
      }
    }
  }


  @override
  void dispose() {
    _fadeController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final dynamicAnimationSize = screenHeight * 0.05;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // --- Conditional Video Background ---
          SizedBox.expand(
            child: _isVideoReady && _videoController!.value.isInitialized
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            )
                : Container(color: Colors.black), // Fallback background
          ),
          // --- Gradient and Blur Overlay ---
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.5),
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          // --- Loading Indicator ---
          // Shows a splash-like loading screen while the video is loading.
          if (_isLoadingVideo)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Logo(
                    size: 150.sp,
                    opacity: 0.8,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  LoadingAnimationWidget.fourRotatingDots(
                      size: dynamicAnimationSize, color: Colors.white),
                ],
              ),
            ),

          if (!_isLoadingVideo)
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                Logo(size: 80.sp, opacity: 0.8),
                                SizedBox(height: 16.h),
                                ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Colors.white, Color.fromARGB(255, 200, 200, 200)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ).createShader(
                                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                  ),
                                  child: Text(
                                    'Satsails',
                                    style: TextStyle(
                                        fontSize: 48.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: Colors.black.withOpacity(0.3),
                                            offset: const Offset(2, 2),
                                          ),
                                        ]
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Your gateway to financial freedom.'.i18n,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      CustomButton(
                        text: 'Create wallet'.i18n,
                        onPressed: () => context.push('/set_pin'),
                        primaryColor: Colors.white.withOpacity(0.2),
                        secondaryColor: Colors.white.withOpacity(0.15),
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 16.h),
                      CustomButton(
                        text: 'Recover wallet'.i18n,
                        onPressed: () => context.push('/recover_wallet'),
                        primaryColor: Colors.white.withOpacity(0.1),
                        secondaryColor: Colors.white.withOpacity(0.1),
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}