// import 'package:flutter/material.dart';
// import 'package:mobileapplication/admindashboard/modal.dart';


// class RegisterPage extends StatefulWidget {
//   @override
//   _RegisterPageState createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isLoading = false;
//   bool _obscurePassword = true;

//   // ... your existing controllers ...

//   Future<void> _handleRegister() async {
//     try {
//       await AuthService.registerWithEmailPassword(
//         context: context,
//         firstName: _nameController.text,
//         lastName: _surnameController.text,
//         username: _usernameController.text,
//         email: _emailController.text,
//         password: _passwordController.text,
//         setLoading: (bool value) => setState(() => _isLoading = value),
//         mounted: mounted,
//       );

//       // Show success dialog and navigate
//       if (mounted) {
//         showDialog(
//           context: context,
//           barrierDismissible: false,
//           builder: (context) => SuccessDialog(
//             onContinue: () => Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const LoginPage()),
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(e.toString()),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _handleGoogleSignIn() async {
//     try {
//       final userCredential = await AuthService.signInWithGoogle(
//         setLoading: (bool value) => setState(() => _isLoading = value),
//         mounted: mounted,
//       );

//       if (userCredential != null && mounted) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const UserDashboard()),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString())),
//         );
//       }
//     }
//   }

//   // ... rest of your widget build method ...
// }