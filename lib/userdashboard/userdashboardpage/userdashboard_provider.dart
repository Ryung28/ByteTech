import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/banpage/ban_period_service.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/userdashboardfirestore_page.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:mobileapplication/config/theme_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserDashboardProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DashboardFirestore _dashboardFirestore = DashboardFirestore();
  String userName = "";
  String? userPhotoUrl;
  DateTime? _startDate;
  DateTime? _endDate;
  bool isLoading = true;
  int currentIndex = 0;
  DateTime? _lastUpdate;
  AnimationController? _animationController;
  List<Animation<double>> animations =
      List.generate(4, (index) => AlwaysStoppedAnimation(0.0));
  StreamSubscription? _banPeriodSubscription;
  final BanPeriodService _banPeriodService = BanPeriodService();

  // Marine data
  Map<String, dynamic> marineData = {
    'temperature': 0.0,
    'windSpeed': 0.0,
    'visibility': 0.0,
    'waveHeight': 0.0,
  };

  // Theme-aware colors
  Color getDeepBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ThemeConfig.lightPrimary
        : ThemeConfig.darkPrimary;
  }

  Color getSurfaceBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ThemeConfig.lightSurface
        : ThemeConfig.darkSurface;
  }

  Color getLightBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ThemeConfig.lightAccent.withOpacity(0.7)
        : ThemeConfig.darkAccent.withOpacity(0.7);
  }

  Color getAccentBlue(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ThemeConfig.lightAccent
        : ThemeConfig.darkAccent;
  }

  Color getWhiteWater(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ThemeConfig.lightCard
        : ThemeConfig.darkCard;
  }

  Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? Colors.white
        : ThemeConfig.darkCard;
  }

  Color getCustomTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.light
        ? ThemeConfig.lightText
        : ThemeConfig.darkText;
  }

  final String _wwoApiKey =
      '65457f7812fb495ab5c93947242411'; // Replace with your actual API key

  void initializeAnimations(TickerProvider vsync) {
    cleanupAnimations();

    try {
      _animationController = AnimationController(
        vsync: vsync,
        duration: const Duration(milliseconds: 300),
      );

      animations = List.generate(4, (index) {
        return Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController!,
            curve: Interval(
              index * 0.1,
              0.1 + index * 0.1,
              curve: Curves.easeOut,
            ),
          ),
        );
      });
    } catch (e) {
    }
  }

  Future<void> loadUserData() async {
    try {
      isLoading = true;
      notifyListeners();

      User? user = _auth.currentUser;
      if (user != null) {
        // First try to find user by Firebase UID
        var userQuery = await _firestore
            .collection('users')
            .where('firebaseUID', isEqualTo: user.uid)
            .get();

        if (userQuery.docs.isEmpty) {
          // Try to find by email
          userQuery = await _firestore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();
        }

        if (userQuery.docs.isNotEmpty) {
          final userData = userQuery.docs.first.data();
          userName = userData['displayName']?.toString() ?? '';
          userPhotoUrl = userData['photoURL']?.toString();

          // If userName is empty, try other fields
          if (userName.isEmpty) {
            final firstName = userData['firstName']?.toString() ?? '';
            final lastName = userData['lastName']?.toString() ?? '';
            if (firstName.isNotEmpty || lastName.isNotEmpty) {
              userName = '$firstName $lastName'.trim();
            } else {
              userName = userData['username']?.toString() ?? 'User';
            }
          }
        }
      }
    } catch (e) {
      userName = 'User';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void updateCurrentIndex(int index) {
    currentIndex = index;

    Future.microtask(() {
      try {
        if (_animationController != null &&
            !_animationController!.isAnimating) {
          _animationController?.reset();
          _animationController?.forward();
        }
      } catch (e) {
      }
    });

    notifyListeners();
  }

  void cleanupAnimations() {
    try {
      if (_animationController != null) {
        if (_animationController!.isAnimating) {
          _animationController!.stop();
        }
        _animationController!.dispose();
        _animationController = null;
      }
    } catch (e) {
      _animationController = null;
    }
  }

  String _currentQuote = '';
  Timer? _quoteTimer;
  final List<String> _inspirationalQuotes = [
    'It takes courage to grow up and become who you really are.',
    'The ocean stirs the heart, inspires the imagination.',
    'In the waves of change, we find our true direction.',
    'Life is like the ocean, it goes up and down.',
    'The sea, once it casts its spell, holds one in its net of wonder forever.',
    'Navigate through life like a ship through storms - with courage and purpose.',
  ];

  String get currentQuote => _currentQuote;

  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;

  String get formattedStartDate {
    return _startDate != null
        ? DateFormat('MMMM d').format(_startDate!)
        : 'Not set';
  }

  String get formattedEndDate {
    return _endDate != null
        ? DateFormat('MMMM d').format(_endDate!)
        : 'Not set';
  }

  @override
  void dispose() {
    _banPeriodSubscription?.cancel();
    _quoteTimer?.cancel();
    cleanupAnimations();
    _animationController = null;
    super.dispose();
  }

  void startQuoteRotation() {
    _currentQuote = _inspirationalQuotes[0];
    notifyListeners();

    _quoteTimer?.cancel();
    _quoteTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      final currentIndex = _inspirationalQuotes.indexOf(_currentQuote);
      final nextIndex = (currentIndex + 1) % _inspirationalQuotes.length;
      _currentQuote = _inspirationalQuotes[nextIndex];
      notifyListeners();
    });
  }

  Future<void> updateMarineData() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      final url = 'https://api.worldweatheronline.com/premium/v1/marine.ashx'
          '?key=$_wwoApiKey'
          '&q=${position.latitude},${position.longitude}'
          '&format=json'
          '&tide=yes'
          '&tp=1'
          '&lang=en';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final weather = data['data']['weather'][0];
        final hourly = weather['hourly'][0];

        marineData = {
          'temperature': double.parse(hourly['tempC']),
          'windSpeed': double.parse(hourly['windspeedKmph']),
          'visibility': double.parse(hourly['visibility']),
          'waveHeight': double.parse(hourly['sigHeight_m']),
        };

        _lastUpdate = DateTime.now();
        notifyListeners();
      } else {
      }
    } catch (e, stackTrace) {
    }
  }

  Future<void> loadBanPeriodData() async {
    try {
      _banPeriodSubscription?.cancel();
      _banPeriodSubscription = _banPeriodService.getCurrentBanPeriod().listen(
        (snapshot) {
          final data = snapshot.data() as Map<String, dynamic>?;
          if (data != null) {
            final startTimestamp = data['startDate'] as Timestamp?;
            final endTimestamp = data['endDate'] as Timestamp?;

            _startDate = startTimestamp?.toDate();
            _endDate = endTimestamp?.toDate();
            notifyListeners();
          }
        },
        onError: (error) {
        },
      );
    } catch (e) {
    }
  }

  Future<void> initializeData() async {
    try {

      if (_animationController != null && !_animationController!.isDismissed) {
        _animationController!.reset();
      }

      // Load data
      await loadUserData();

      // Then load other data concurrently
      await Future.wait([
        loadBanPeriodData(),
        updateMarineData(),
      ], eagerError: true);

      // Start animations and quote rotation
      if (_animationController != null) {
        _animationController!.forward();
      }
      startQuoteRotation();

    } catch (e) {
      // Ensure we have a fallback name even if loading fails
      if (userName.isEmpty) {
        userName = "User";
        notifyListeners();
      }
    }
  }

  void setAnimationController(AnimationController controller) {
    _animationController = controller;
  }

  Color getThemeAwareColor(BuildContext context,
      {required Color lightColor, required Color darkColor}) {
    return Theme.of(context).brightness == Brightness.light
        ? lightColor
        : darkColor;
  }

  Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).primaryColor;
  }

  Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor;
  }

  Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }

  Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onBackground;
  }
}
