import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobileapplication/authenticationpages/loginpage/login_page.dart';
import 'package:mobileapplication/authenticationpages/registerpage/email_verification_service.dart';
import 'package:mobileapplication/authenticationpages/registerpage/registrationfirestore.dart';
import 'package:mobileapplication/authenticationpages/verificationpage/verification_page.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2196F3)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2196F3),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please fill in the form to continue',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),
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
                          label: "Last Name",
                          hintText: "Enter your last name",
                          controller: _surnameController,
                          validator: (value) => value!.isEmpty
                              ? "Please enter your last name"
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
                              : !value.contains('@')
                                  ? "Please enter a valid email"
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
                              : value.length < 6
                                  ? "Password must be at least 6 characters"
                                  : null,
                        ),
                        const SizedBox(height: 10),
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
                          label: "Create Account",
                        ),
                        RegisterWidgets.myloginRedirect(
                          onLoginTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginPage()),
                          ),
                        ),
                        RegisterWidgets.buildDividerOr(),
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
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> handleRegistration({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController surnameController,
    required TextEditingController usernameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required Function(bool) setLoading,
    required bool mounted,
  }) async {
    if (_formKey.currentState!.validate()) {
      setLoading(true);
      try {
        final result = await Firestore().addUser(
          firstName: nameController.text,
          lastName: surnameController.text,
          username: usernameController.text,
          email: emailController.text,
          password: passwordController.text,
        );

        if (!mounted) return;

        // Send verification email with OTP
        final verificationService = EmailVerificationService();
        await verificationService.sendOTPEmail(
          emailController.text,
          result['otp'] as String,
        );

        if (!mounted) return;

        // Show success message and wait for it to be shown
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Please check your inbox.'),
            duration: Duration(seconds: 2),
          ),
        );

        // Add a small delay to ensure SnackBar is visible before navigation
        await Future.delayed(const Duration(seconds: 1));

        if (!mounted) return;

        // Navigate to verification page
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => VerificationPage(
              uid: (result['user'] as UserCredential).user!.uid,
              email: emailController.text,
              otp: result['otp'] as String,
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      } finally {
        if (mounted) setLoading(false);
      }
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      obscure = !obscure;
    });
  }
}
