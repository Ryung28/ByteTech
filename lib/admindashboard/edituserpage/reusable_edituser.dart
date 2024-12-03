import 'package:flutter/material.dart';
import 'package:mobileapplication/models/usermanagementmodel.dart';


class EditUserWidgets {
  static Widget buildHeader(BuildContext context, UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const SizedBox(width: 8),
          Text(
            user == null ? 'Add New User' : 'Edit User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: onTogglePassword,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  static Widget buildAdminSwitch({
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: const Text('Admin Access'),
      subtitle: const Text('Grant administrative privileges'),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue,
    );
  }

  static Future<void> handleSubmit({
    required GlobalKey<FormState> formKey,
    required UserModel? user,
    required TextEditingController firstNameController,
    required TextEditingController lastNameController,
    required TextEditingController usernameController,
    required TextEditingController emailController,
    required TextEditingController passwordController,
    required bool isAdmin,
    required BuildContext context,
    required Function(bool) setLoading,
  }) async {
    if (!formKey.currentState!.validate()) return;

    setLoading(true);
    try {
      // TODO: Implement your user creation/update logic here
      await Future.delayed(const Duration(seconds: 1)); // Simulated API call
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setLoading(false);
    }
  }
} 