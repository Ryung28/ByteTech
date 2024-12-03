import 'package:flutter/material.dart';
import 'package:mobileapplication/authenticationpages/loginpage/login_page.dart';
import '../../reusable_widget/reusable_widget.dart';
import 'reusable_registerpage.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with RegistrationHandler {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildRegistrationHeader(),
                    SizedBox(height: screenHeight * 0.03),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          RegisterWidgets.mybuildTextForm(
                            icons: Icons.person_outline,
                            label: "First Name",
                            hintText: "Enter your first name",
                            controller: _nameController,
                            validator: (value) => value!.isEmpty
                                ? "Please enter your first name"
                                : null,
                          ),
                          RegisterWidgets.mybuildTextForm(
                            icons: Icons.person_outline,
                            label: "Surname",
                            hintText: "Enter your surname",
                            controller: _surnameController,
                            validator: (value) => value!.isEmpty
                                ? "Please enter your surname"
                                : null,
                          ),
                          RegisterWidgets.mybuildTextForm(
                            icons: Icons.alternate_email,
                            label: "Username",
                            hintText: "Enter your username",
                            controller: _usernameController,
                            validator: (value) => value!.isEmpty
                                ? "Please enter your username"
                                : null,
                          ),
                          RegisterWidgets.mybuildTextForm(
                            icons: Icons.email_outlined,
                            label: "Email",
                            hintText: "Enter your email",
                            controller: _emailController,
                            validator: (value) => value!.isEmpty
                                ? "Please enter your email"
                                : null,
                          ),
                          RegisterWidgets.mybuildTextForm(
                            icons: Icons.lock_outline,
                            label: "Password",
                            hintText: "Enter your password",
                            isPassword: true,
                            obscure: obscure,
                            onVisible: _togglePasswordVisibility,
                            controller: _passwordController,
                            validator: (value) => value!.isEmpty
                                ? "Please enter your password"
                                : null,
                          ),
                          const SizedBox(height: 24),
                          RegisterWidgets.myregisterButton(
                            onPressed: () => handleRegistration(
                              context: context,
                              nameController: _nameController,
                              surnameController: _surnameController,
                              usernameController: _usernameController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              setLoading: (bool value) =>
                                  setState(() => _isLoading = value),
                              mounted: mounted,
                            ),
                            label: "Register",
                          ),
                          RegisterWidgets.myloginRedirect(
                            onLoginTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            ),
                          ),
                          RegisterWidgets.buildGoogleAuthButton(
                            onPressed: () {
                              OAuthHandler.handleGoogleSignIn(
                                context: context,
                                setLoading: (bool value) =>
                                    setState(() => _isLoading = value),
                                mounted: mounted,
                              );
                            },
                          ),
                        ],
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
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      obscure = !obscure;
    });
  }
}
