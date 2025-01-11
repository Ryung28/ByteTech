// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:mobileapplication/userdashboard/ocean_educations_hub.dart';
// import 'package:mobileapplication/userdashboard/ocean_education.dart';
// import 'package:mobileapplication/userdashboard/usersettingspage/usersettings_page.dart';

// final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

// final goRouter = GoRouter(
//   navigatorKey: _rootNavigatorKey,
//   initialLocation: '/ocean-hub',
//   routes: [
//     GoRoute(
//       path: '/ocean-hub',
//       name: 'ocean-hub',
//       builder: (context, state) => const OceanEducationHub(),
//     ),
//     GoRoute(
//       path: '/marine-education/:category',
//       name: 'marine-education',
//       builder: (context, state) {
//         final category = state.pathParameters['category'] ?? '';
//         return MarineEducationPage(category: category);
//       },
//     ),
//     GoRoute(
//       path: '/user-settings',
//       name: 'user-settings',
//       builder: (context, state) => const UsersettingsPage(),
//     ),
//   ],
//   errorBuilder: (context, state) => Scaffold(
//     body: Center(
//       child: Text('Page not found: ${state.error}'),
//     ),
//   ),
// );
