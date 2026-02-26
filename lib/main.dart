import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'services/admob_service.dart';
import 'viewmodels/image_generator_viewmodel.dart';
import 'views/selection_screen.dart';
import 'views/prompt_learner_view.dart';
import 'views/home_view_fantastic.dart';
import 'views/settings_view.dart';
import 'views/splash_screen.dart';
import 'utils/app_theme.dart';

// Global App Open Ad manager accessible across the app
final AppOpenAdManager appOpenAdManager = AppOpenAdManager();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize AdMob SDK
  await MobileAds.instance.initialize();
  debugPrint('[AdMob] SDK initialized.');

  // Preload all ad types (App Open, Interstitial, Rewarded) at startup
  appOpenAdManager.preloadAll();

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Request photos permission on startup (photosAddOnly for saving images)
  await Permission.photosAddOnly.request();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // No lifecycle observer needed — App Open Ad only shows on cold launch.
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ImageGeneratorViewModel()..loadHistory(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vertex Ai Studio',
        theme: AppTheme.darkTheme,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/': (context) => const SelectionScreen(),
          '/prompt-learner': (context) => const PromptLearnerView(),
          '/generator': (context) => const HomeViewFantastic(),
          '/settings': (context) => const SettingsView(),
        },
      ),
    );
  }
}
