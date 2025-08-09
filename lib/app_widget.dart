import 'dart:async';
import 'dart:ui';
import 'package:Satsails/providers/settings_provider.dart';
import 'package:Satsails/screens/shared/transaction_notifications_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:i18n_extension/i18n_extension.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './app_router.dart';

/// The root widget of the application that manages lifecycle and theming.
class AppWidget extends ConsumerStatefulWidget {
  const AppWidget({super.key});

  @override
  ConsumerState<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends ConsumerState<AppWidget> with WidgetsBindingObserver {
  late final GoRouter _router;
  late final StreamSubscription<Map> _branchSubscription;

  DateTime? _pauseTime;
  bool _isFirstResume = true;
  bool _isBlurred = false;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter('/splash');
    WidgetsBinding.instance.addObserver(this);
    _initializeDeepLinkListener();
    _setSystemUIOverlayStyle();
  }

  void _initializeDeepLinkListener() {
    _branchSubscription = FlutterBranchSdk.listSession().listen((data) async {
      if (data.containsKey("affiliateCode")) {
        final insertedAffiliateCode = data["affiliateCode"];
        final upperCaseCode = insertedAffiliateCode.toUpperCase();
        final box = await Hive.openBox('user');
        final currentInsertedAffiliateCode = box.get('affiliateCode', defaultValue: '');
        if (insertedAffiliateCode != null && currentInsertedAffiliateCode.isEmpty) {
          box.put('affiliateCode', upperCaseCode);
        }
      }
    });
  }

  void _setSystemUIOverlayStyle() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResume();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _handleAppPause();
        break;
      case AppLifecycleState.detached:
      // Do nothing when detached, as the view is gone.
        break;
    }
  }

  void _handleAppResume() {
    if (mounted) {
      setState(() => _isBlurred = false);
    }

    if (_isFirstResume) {
      _isFirstResume = false;
      _pauseTime = null;
      return;
    }

    const gracePeriod = Duration(seconds: 180);
    if (_pauseTime != null) {
      final elapsed = DateTime.now().difference(_pauseTime!);
      if (elapsed > gracePeriod) {
        _router.go('/splash');
      }
    }
    _pauseTime = null;
  }

  void _handleAppPause() {
    if (mounted) {
      setState(() => _isBlurred = true);
    }
    _pauseTime ??= DateTime.now();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _branchSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(settingsProvider).language;
    I18n.define(Locale(language));

    return TransactionNotificationsListener(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            ScreenUtilInit(
              designSize: const Size(430, 932),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp.router(
                  routerConfig: _router,
                  locale: Locale(language),
                  themeMode: ThemeMode.dark,
                  darkTheme: ThemeData(
                    brightness: Brightness.dark,
                    scaffoldBackgroundColor: Colors.black,
                    appBarTheme: const AppBarTheme(
                      backgroundColor: Colors.black,
                      elevation: 0,
                    ),
                  ),
                  debugShowCheckedModeBanner: false,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('en'),
                    Locale('pt'),
                  ],
                  builder: (context, child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      child: I18n(
                        initialLocale: Locale(language),
                        child: child!,
                      ),
                    );
                  },
                );
              },
            ),
            if (_isBlurred)
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
