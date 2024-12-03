import 'package:flutter/material.dart';
import 'package:mobileapplication/authenticationpages/loginpage/login_page.dart';

// Success Modal for register page
class SuccessDialog extends StatelessWidget {
  final VoidCallback onContinue;

  const SuccessDialog({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 60,
          ),
          SizedBox(height: 10),
          Text(
            'Registration Successful!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      content: Text(
        'Your account has been successfully created.',
        textAlign: TextAlign.center,
      ),
      actions: [
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: onContinue,
            child: Text('Continue'),
          ),
        ),
      ],
    );
  }
}

// Function to show the success dialog
void showSuccessDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return SuccessDialog(
        onContinue: () {
          Navigator.of(context).pop(); // Close the dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
      );
    },
  );
}
