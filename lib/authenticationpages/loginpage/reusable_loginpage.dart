import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_page.dart';
import 'package:mobileapplication/authenticationpages/loginpage/loginfirestore.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';
import 'package:mobileapplication/userdashboard/userdashboardpage/user_dashboard.dart';
import 'package:mobileapplication/authenticationpages/authentication_pages/forgot_password_page.dart';

// Login Form Widget
class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscure;
  final VoidCallback togglePasswordVisibility;
  final VoidCallback onLogin;
  final bool isLoading;
  final VoidCallback onRegisterTap;
  final bool mounted;
  final Function(bool) setLoading;
  final VoidCallback onGoogleSignIn;

  const LoginForm({
    Key? key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscure,
    required this.togglePasswordVisibility,
    required this.onLogin,
    required this.isLoading,
    required this.onRegisterTap,
    required this.mounted,
    required this.setLoading,
    required this.onGoogleSignIn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate responsive logo size
    final double logoSize = screenHeight * 0.15;
    final double maxLogoSize = screenWidth * 0.3;
    final double finalLogoSize = logoSize > maxLogoSize ? maxLogoSize : logoSize;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isKeyboardVisible) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: logoWidget(
                Theme.of(context).brightness == Brightness.dark
                    ? 'assets/MarineGuard-Logo-preview.png'
                    : 'assets/MarineGuard-Logo-preview.png',
                finalLogoSize,
                finalLogoSize,
              ),
            ),
            myText('Login'),
          ],
          const SizedBox(height: 20),
          loginFormContainer(
            context: context,
            isKeyboardVisible: isKeyboardVisible,
            child: Column(
              children: [
                myTextform(
                  icons: Icons.person,
                  label: 'Email Address',
                  obscure: false,
                  isPassword: false,
                  controller: emailController,
                  validator: validateEmail,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  inputDecoration: InputDecoration(
                    hintText: 'Enter your email',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.person,
                      color: Colors.grey.shade600,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 25, 115, 232),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade300),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    ),
                  ),
                ),
                myTextform(
                  icons: Icons.lock,
                  label: 'Password',
                  obscure: obscure,
                  isPassword: true,
                  onVisible: togglePasswordVisibility,
                  controller: passwordController,
                  validator: validatePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => onLogin(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                  inputDecoration: InputDecoration(
                    hintText: 'Enter your password',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.grey.shade600,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: togglePasswordVisibility,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 25, 115, 232),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade300),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: socialLoginButton(
                    onPressed: isLoading ? () {} : onLogin,

                    label: isLoading ? 'Logging in...' : 'Login',
                    backgroundColor: const Color.fromARGB(255, 34, 38, 71),
                    textColor: Colors.white,
                    width: double.infinity,
                    iconSize: 45,
                  ),
                ),
                socialLoginButtons(
                  context: context,
                  isLoading: isLoading,
                  setLoading: setLoading,
                  mounted: mounted,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordPage(
                              prefilledEmail: emailController.text.trim(),
                            ),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          letterSpacing: 0.3,
                          decoration: TextDecoration.none,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                loginDividerWithText(),
                SizedBox(
                  width: double.infinity,
                  child: myButton(
                    'Sign up here',
                    labelstyle: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Quicksand',
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                      decorationThickness: 2,
                    ),
                    onTap: isLoading ? null : onRegisterTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget loginPageBackground({
  required BuildContext context,
  required Widget child,
}) {
  final screenHeight = MediaQuery.of(context).size.height;

  return Stack(
    children: [
      Image(
        image: const AssetImage('assets/MarineGaurdBackground.jpg'),
        height: screenHeight,
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      ),
      SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenHeight - MediaQuery.of(context).padding.top,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: child,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget loginFormContainer({
  required BuildContext context,
  required bool isKeyboardVisible,
  required Widget child,
}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: EdgeInsets.only(top: isKeyboardVisible ? 0 : 20),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Container(
          width: min(380, MediaQuery.of(context).size.width - 40),
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: isKeyboardVisible ? 10 : 20,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    ),
  );
}

Widget loginDividerWithText() {
  return Row(
    children: [
      Expanded(child: Divider(color: Colors.white70, thickness: 1)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(
          "Don't have an account?",
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ),
      Expanded(child: Divider(color: Colors.white70, thickness: 1))
    ],
  );
}

Widget socialLoginButtons({
  required BuildContext context,
  required bool isLoading,
  required Function(bool) setLoading,
  required bool mounted,
}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: socialLoginButton(
      onPressed: () {
        if (!isLoading) {
          OAuthHandler.handleGoogleSignIn(
            context: context,
            setLoading: setLoading,
            mounted: mounted,
          );
        }
      },
      icon: 'assets/google-logo.png',
      label: 'Continue with Google',
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      width: double.infinity,
    ),
  );
}

// Login Handler Mixin
mixin LoginHandler {
  Future<void> handleLogin({
    required BuildContext context,
    required GlobalKey<FormState> formKey,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required AuthService authService,
    required FirebaseAuth auth,
    required Function(bool) setLoading,
    required bool mounted,
  }) async {
    if (!_validateLoginInput(
        context, formKey, emailController, passwordController)) {
      return;
    }

    try {
      setLoading(true);

      // Show loading indicator using a separate method
      if (mounted) {
        _showLoadingDialog(context);
      }

      // Handle login in a separate isolate or compute
      await Future(() async {
        final userCredential = await authService
            .signInWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text,
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () => throw TimeoutException('Login timeout'),
            );

        if (!mounted) return;

        // Get user data
        final userData =
            await authService.getUserData(userCredential.user!.uid);

        if (!mounted) return;

        // Pop loading dialog and handle success
        Navigator.of(context).pop(); // Remove loading dialog
        await _handleLoginSuccess(context, userData);
      }).catchError((error) {
        if (mounted) {
          Navigator.of(context).pop(); // Remove loading dialog
          _showErrorSnackbar(context, error.toString());
        }
      });
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Remove loading dialog
        _showErrorSnackbar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setLoading(false);
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: const Center(
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Logging in...'),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _validateLoginInput(
    BuildContext context,
    GlobalKey<FormState> formKey,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) {
    if (!formKey.currentState!.validate()) return false;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return false;
    }

    return true;
  }

  Future<void> _handleLoginSuccess(
    BuildContext context,
    DocumentSnapshot userData,
  ) async {
    if (!userData.exists) {
      _showErrorSnackbar(context, 'User data not found');
      return;
    }

    final bool isAdmin = userData.get('isAdmin') ?? false;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isAdmin ? const AdmindashboardPage() : const UserDashboard(),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
