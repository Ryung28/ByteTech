import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_page.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/widgets/admin_analytics_reusablewidget/services/analytics_firestore.dart';
import 'package:mobileapplication/admindashboard/providers/admindashboard_provider.dart';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:mobileapplication/firebase_options.dart';
import 'package:mobileapplication/providers/navigation_provider.dart';
import 'package:mobileapplication/providers/theme_provider.dart';
import 'package:mobileapplication/userdashboard/usersettingspage/usersettings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await FirebaseAuth.instance.signInAnonymously();
    print('Signed in anonymously');
  } catch (e) {
    print('Anonymous auth failed: $e');
  }

  final prefs = await SharedPreferences.getInstance();

  final analyticsService = AnalyticsService();
  await analyticsService.initializeAnalytics();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
          routes: {
            '/': (context) => const AdmindashboardPage(),
            '/admin': (context) => const AdmindashboardPage(),
          },
        );
      },
    );
  }
}

class LifecycleManager extends StatefulWidget {
  final Widget child;

  const LifecycleManager({Key? key, required this.child}) : super(key: key);

  @override
  _LifecycleManagerState createState() => _LifecycleManagerState();
}

class _LifecycleManagerState extends State<LifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        // Remove Firebase reinitialization
        break;
      case AppLifecycleState.inactive:
        // App is in an inactive state
        break;
      case AppLifecycleState.paused:
        // App is in background
        break;
      case AppLifecycleState.detached:
        // App is closed
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
