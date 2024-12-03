import 'package:flutter/material.dart';
import 'package:mobileapplication/reusable_widget/reusable_widget.dart';


class RegisterWidgets {
  static Widget mybuildTextForm({
    IconData? icons,
    bool obscure = false,
    bool isPassword = false,
    String? label,
    String? hintText,
    VoidCallback? onVisible,
    TextEditingController? controller,
    FormFieldValidator<String>? validator,
  }) {
    return Container(
      height: 70,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? obscure : false,
        validator: validator,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            color: Color.fromARGB(255, 0, 102, 255),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icons, color: const Color.fromARGB(255, 0, 102, 255)),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: const Color.fromARGB(255, 0, 102, 255),
                  ),
                  onPressed: onVisible,
                )
              : null,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color.fromARGB(255, 0, 102, 255),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }

  static Widget myregisterButton({VoidCallback? onPressed, String? label}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        minimumSize: const Size(double.infinity, 55),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        label ?? "",
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget myloginRedirect({VoidCallback? onLoginTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.grey),
        ),
        GestureDetector(
          onTap: onLoginTap,
          child: const Text(
            "Login",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static Widget mybuildSuccessDialog({required VoidCallback onContinue}) {
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

  static void myshowSuccessDialog(BuildContext context, VoidCallback onContinue) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return mybuildSuccessDialog(onContinue: onContinue);
      },
    );
  }

  static Widget buildGoogleAuthButton({VoidCallback? onPressed}) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      child: socialLoginButton(
        onPressed: onPressed ?? () {},
        icon: 'assets/google-logo.png',
        label: 'Sign up with Google',
        backgroundColor: Colors.white,
        textColor: Colors.black87,
        width: double.infinity,
      ),
    );
  }
}