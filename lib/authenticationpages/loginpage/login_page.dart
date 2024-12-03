import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapplication/authenticationpages/registerpage/register_page.dart';
import 'package:mobileapplication/firebase/loginfirestore.dart';
import 'package:mobileapplication/authenticationpages/authentication_pages/registerpage/register_page.dart';
import 'package:mobileapplication/authenticationpages/loginpage/reusable_loginpage.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with LoginHandler {
  final _formKey = GlobalKey<FormState>();
  final emailAddressController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool obscure = true;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          loginPageBackground(
            context: context,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoginForm(
                      formKey: _formKey,
                      emailController: emailAddressController,
                      passwordController: passwordController,
                      obscure: obscure,
                      togglePasswordVisibility: () =>
                          setState(() => obscure = !obscure),
                      onLogin: () => handleLogin(
                        context: context,
                        formKey: _formKey,
                        emailController: emailAddressController,
                        passwordController: passwordController,
                        authService: _authService,
                        auth: _auth,
                        setLoading: (bool value) =>
                            setState(() => _isLoading = value),
                        mounted: mounted,
                      ),
                      isLoading: _isLoading,
                      onRegisterTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()),
                      ),
                      mounted: mounted,
                      setLoading: (bool value) =>
                          setState(() => _isLoading = value),
                      onGoogleSignIn: () => OAuthHandler.handleGoogleSignIn(
                        context: context,
                        setLoading: (bool value) =>
                            setState(() => _isLoading = value),
                        mounted: mounted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.fromARGB(255, 34, 38, 71),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}