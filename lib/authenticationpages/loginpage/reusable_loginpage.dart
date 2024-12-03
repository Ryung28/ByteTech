import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_page.dart';
import 'package:mobileapplication/firebase/loginfirestore.dart';
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
    final double logoSize = screenHeight * 0.2;
    final double maxLogoSize = screenWidth * 0.4;
    final double finalLogoSize =
        logoSize > maxLogoSize ? maxLogoSize : logoSize;

    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isKeyboardVisible) ...[
            logoWidget(
              'assets/MarineGuard-Logo-preview.png',
              finalLogoSize,
              finalLogoSize,
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
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 25, 115, 232),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red.shade300),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
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
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 25, 115, 232),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red.shade300),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide(color: Colors.red.shade400),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: myButton2(
                    context,
                    isLoading ? 'Logging in...' : 'Login',
                    isLoading ? null : onLogin,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                      decorationThickness: 2,
                      decorationColor: Colors.white,
                    ),
                    decoration: BoxDecoration(
                      color: isLoading
                          ? Colors.grey
                          : const Color.fromARGB(255, 34, 38, 71),
                      borderRadius: BorderRadius.circular(30),
                    ),
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
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
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
  return Column(
    children: [
      const SizedBox(height: 10),
      // ignore: sized_box_for_whitespace
      Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: isLoading
              ? null
              : () => OAuthHandler.handleGoogleSignIn(
                    context: context,
                    setLoading: setLoading,
                    mounted: mounted,
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          icon: Image.asset(
            'assets/google-logo.png',
            height: 24,
            width: 24,
          ),
          label: const Text(
            'Continue with Google',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    ],
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
    if (!formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showErrorModal(
          context, 'Missing Information', 'Please fill in all fields');
      return;
    }

    setLoading(true);

    try {
      final UserCredential userCredential =
          await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;

      if (userData.exists) {
        final bool isAdmin = userData.data()?['isAdmin'] ?? false;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                isAdmin ? const AdmindashboardPage() : const UserDashboard(),
          ),
        );
      } else {
        showErrorModal(context, 'Error', 'User data not found.');
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = 'An error occurred while trying to log in.';

      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password') {
        message = 'Invalid password.';
      }

      showErrorModal(context, 'Login Failed', message);
    } catch (e) {
      if (!mounted) return;
      showErrorModal(context, 'Login Failed',
          'An error occurred while trying to log in. Please try again.');
    } finally {
      if (mounted) {
        setLoading(false);
      }
    }
  }
}
