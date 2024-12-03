import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController {
  final TextEditingController emailController;
  final GlobalKey<FormState> formKey;
  final BuildContext context;
  final Function(bool) setLoading;
  final bool mounted;

  ForgotPasswordController({
    required this.emailController,
    required this.formKey,
    required this.context,
    required this.setLoading,
    required this.mounted,
  });

  Future<bool> checkEmailExists(String email) async {
    try {
      final List<String> signInMethods = 
          await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      
      if (signInMethods.isEmpty) return false;

      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error checking email: $e');
      return false;
    }
  }

  Future<void> handleResetPassword() async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);

    try {
      final email = emailController.text.trim();
      final bool emailExists = await checkEmailExists(email);
      
      if (!emailExists) {
        if (!mounted) return;
        _showErrorSnackBar('No account found with this email address.');
        return;
      }

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      if (!mounted) return;
      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message = e.code == 'invalid-email' 
          ? 'Please enter a valid email address.'
          : 'An error occurred while resetting password.';
      _showErrorSnackBar(message);
    } finally {
      if (mounted) setLoading(false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mark_email_read,
                size: 50,
                color: Color.fromARGB(255, 34, 38, 71),
              ),
              const SizedBox(height: 20),
              const Text(
                'Email Sent!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 34, 38, 71),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Password reset link has been sent to:\n${emailController.text}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to login page
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 34, 38, 71),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 45),
                ),
                child: const Text(
                  'Back to Login',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}