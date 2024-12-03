import 'package:flutter/material.dart';
import 'package:mobileapplication/firebase/userdashboardfirestore_page.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:mobileapplication/config/theme_config.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardFirestore _dashboardFirestore = DashboardFirestore();
  String userName = "";
  String startDate = "July 7";
  String endDate = "July 9";
  bool isLoading = true;
  int currentIndex = 0;
  DateTime? _lastUpdate;
  AnimationController? _animationController;
  List<Animation<double>> animations = List.generate(4, (index) => 
    AlwaysStoppedAnimation(0.0)
  );

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

  final String _wwoApiKey = '65457f7812fb495ab5c93947242411';  // Replace with your actual API key


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
      print('Animation initialization error: $e');
    }
  }

  Future<void> loadUserData() async {
    try {
      isLoading = true;
      notifyListeners();

      userName = await _dashboardFirestore.getUserName();
    } catch (e) {
      print('Error loading user data: $e');
      userName = "User";
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
        print('Animation error handled: $e');
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
      print('Cleanup error handled: $e');
      _animationController = null;
    }
  }

  @override
  void dispose() {
    cleanupAnimations();
    _animationController = null;
    super.dispose();
  }

  Future<void> updateMarineData() async {
    try {
      print('Checking location permission...');
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('Location permissions are denied');
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        print('Location permissions are permanently denied');
        return;
      }

      print('Starting marine data update...');
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      print('Got position: ${position.latitude}, ${position.longitude}');

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
        print('Updated Marine Data: $marineData');
        notifyListeners();
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e, stackTrace) {
      print('Error updating marine data: $e');
      print('Stack trace: $stackTrace');
    }
  }

  Future<void> initializeData() async {
    await loadUserData();
    await updateMarineData();
    if (_animationController != null && !_animationController!.isDismissed) {
      _animationController!.forward();
    }
  }

  void setAnimationController(AnimationController controller) {
    _animationController = controller;
  }

  Color getThemeAwareColor(BuildContext context, {required Color lightColor, required Color darkColor}) {
    return Theme.of(context).brightness == Brightness.light ? lightColor : darkColor;
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