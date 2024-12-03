import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/authenticationpages/authentication_pages/forgot_password_logic.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';
import 'package:mobileapplication/authenticationpages/loginpage/reusable_loginpage.dart';
import 'dart:ui';

class ForgotPasswordPage extends StatefulWidget {
  final String? prefilledEmail;

  const ForgotPasswordPage({Key? key, this.prefilledEmail}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _isLoading = false;
  late final ForgotPasswordController _controller;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefilledEmail);
    _controller = ForgotPasswordController(
      emailController: _emailController,
      formKey: _formKey,
      context: context,
      setLoading: (bool value) => setState(() => _isLoading = value),
      mounted: mounted,
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4A90E2);
    final surfaceColor = Colors.white;
    final backgroundColor = const Color(0xFFF8FAFD);
    final textColor = const Color(0xFF2D3748);
    final subtextColor = const Color(0xFF718096);

    return Scaffold(
      body: loginPageBackground(
        context: context,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Enhanced floating form with layered shadows
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        // Outer shadow
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 40,
                          spreadRadius: 10,
                          offset: const Offset(0, 20),
                        ),
                        // Inner shadow
                        BoxShadow(
                          color: primaryColor.withOpacity(0.05),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: surfaceColor.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          padding: const EdgeInsets.fromLTRB(30, 40, 30, 40),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Modern stacked icon
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            primaryColor.withOpacity(0.1),
                                            primaryColor.withOpacity(0.2),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: surfaceColor.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                primaryColor.withOpacity(0.2),
                                            blurRadius: 10,
                                            spreadRadius: -5,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        Icons.lock_reset_rounded,
                                        size: 32,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                // Modern title with background highlight
                                Text(
                                  'Reset Password',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Modern description with container
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: backgroundColor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: primaryColor.withOpacity(0.1),
                                    ),
                                  ),
                                  child: Text(
                                    "Enter your email and we'll send you instructions to reset your password",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: subtextColor,
                                      fontSize: 15,
                                      height: 1.5,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 35),
                                // Enhanced input field
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.04),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: TextFormField(
                                    controller: _emailController,
                                    validator: validateEmail,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 15,
                                      letterSpacing: 0.1,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your email',
                                      hintStyle: TextStyle(
                                        color: subtextColor.withOpacity(0.7),
                                        fontSize: 15,
                                      ),
                                      filled: true,
                                      fillColor: backgroundColor,
                                      prefixIcon: Icon(
                                        Icons.email_outlined,
                                        color: subtextColor,
                                        size: 22,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(
                                          color: primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                // Enhanced button with shadow
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                        spreadRadius: -5,
                                      ),
                                    ],
                                  ),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _controller.handleResetPassword,
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: primaryColor,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ).copyWith(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                          (states) {
                                            if (states.contains(
                                                MaterialState.disabled)) {
                                              return Colors.grey.shade300;
                                            }
                                            return primaryColor;
                                          },
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : const Text(
                                              'Send Instructions',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
