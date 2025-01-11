import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_provider.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/services/analytics_firestore.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/providers/reports_provider.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/firebase_options.dart';
import 'package:mobileapplication/providers/navigation_provider.dart';
import 'package:mobileapplication/providers/theme_provider.dart';
import 'package:mobileapplication/services/auth_service.dart';
import 'package:mobileapplication/splashscreen/spashscreen_page.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/userdashboard_provider.dart';
import 'package:mobileapplication/userdashboard/usersettingspage/usersettings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/firestore_service.dart';
import 'package:mobileapplication/admindashboard/banpage/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final authService = AuthService();
    await authService.initialize();

    await NotificationService.initialize();
    await NotificationService.requestPermissions();
    await NotificationService.listenToBanPeriodChanges();

    if (!kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      await prefs.setBool('isFirstRun', false);
      if (kDebugMode) {
        print('First run of the app');
      }
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      print('Auth state changed: ${user?.uid}');
    });

    final analyticsService = AnalyticsService();
    await analyticsService.initializeAnalytics();
    await FirestoreService.initializeCounter();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(create: (_) => UserDashboardProvider()),
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ChangeNotifierProvider(create: (_) => DashboardProvider()),
          ChangeNotifierProvider(create: (_) => ReportsProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Initialization Error: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Marine Guard',
          theme: themeProvider.isDarkMode
              ? ThemeConfig.darkTheme
              : ThemeConfig.lightTheme,
          home: Builder(
            builder: (context) {
              return const SplashScreen();
            },
          ),

        );
      },
    );
  }
}
