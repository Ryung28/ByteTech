import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mobileapplication/reusable_widget/bottom_nav_bar.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/reusable_complaintpage.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/complaint_provider.dart';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({Key? key}) : super(key: key);

  @override
  State<ComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<ComplaintPage> {
  static const int currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ComplaintFormProvider(),
      child: Scaffold(
        body: Stack(
          children: [
            const ReusableComplaintPage(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: FloatingNavBar(
                currentIndex: currentIndex,
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Form field builders
  static Widget buildNameField(BuildContext context, ComplaintFormProvider state) {
    return _buildFormField(
      context: context,
      label: 'Full Name',
      icon: Icons.person,
      validator: (value) => value?.isEmpty ?? true ? 'Please enter your name' : null,
      onSaved: (value) => state.updateName(value ?? ''),
    );
  }

  static Widget buildDateOfBirthField(BuildContext context, ComplaintFormProvider state) {
    return _buildFormField(
      context: context,
      label: 'Date of Birth',
      icon: Icons.calendar_today,
      readOnly: true,
      onTap: () => _showDatePicker(context, state),
      validator: (value) => value?.isEmpty ?? true ? 'Please select your date of birth' : null,
      controller: TextEditingController(
        text: state.dateOfBirth != null
            ? DateFormat('MMMM dd, yyyy').format(state.dateOfBirth!)
            : '',
      ),
    );
  }

  static Widget buildPhoneField(BuildContext context, ComplaintFormProvider state) {
    return _buildFormField(
      context: context,
      label: 'Phone Number',
      icon: Icons.phone,
      keyboardType: TextInputType.phone,
      validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
      onSaved: (value) => state.updatePhone(value ?? ''),
    );
  }

  static Widget buildEmailField(BuildContext context, ComplaintFormProvider state) {
    return _buildFormField(
      context: context,
      label: 'Email Address',
      icon: Icons.email,
      keyboardType: TextInputType.emailAddress,
      validator: (value) => value?.isEmpty ?? true ? 'Please enter your email' : null,
      onSaved: (value) => state.updateEmail(value ?? ''),
    );
  }

  static Widget buildAddressField(BuildContext context, ComplaintFormProvider state) {
    return _buildFormField(
      context: context,
      label: 'Complete Address',
      icon: Icons.location_on,
      maxLines: 3,
      validator: (value) => value?.isEmpty ?? true ? 'Please enter your address' : null,
      onSaved: (value) => state.updateAddress(value ?? ''),
    );
  }

  static Widget buildComplaintField(BuildContext context, ComplaintFormProvider state) {
    return _buildFormField(
      context: context,
      label: 'Complaint Details',
      icon: Icons.description,
      maxLines: 5,
      hintText: 'Please provide detailed information about your complaint...',
      validator: (value) => value?.isEmpty ?? true ? 'Please enter your complaint' : null,
      onSaved: (value) => state.updateComplaint(value ?? ''),
    );
  }

  static Widget buildFileUploadButton(BuildContext context, ComplaintFormProvider state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0),
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF64B5F6), const Color(0xFF42A5F5)]
              : [const Color(0xFF1E88E5), const Color(0xFF1976D2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.2) 
                : const Color(0xFF1E88E5).withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => _pickFile(state),
        icon: const Icon(Icons.upload_file, color: Colors.white, size: 20),
        label: const Text(
          'Upload Documents',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Helper methods
  static Future<void> _showDatePicker(BuildContext context, ComplaintFormProvider state) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF003366),
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (date != null) {
      state.updateDateOfBirth(date);
    }
  }

  static Future<void> _pickFile(ComplaintFormProvider state) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      state.addFile(File(pickedFile.path));
    }
  }

  static Widget _buildFormField({
    required BuildContext context,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLines,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
    TextEditingController? controller,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: TextFormField(
        style: const TextStyle(fontSize: 14),
        decoration: inputDecoration(label, icon, context).copyWith(
          hintText: hintText,
          alignLabelWithHint: maxLines != null && maxLines > 1,
          isDense: true,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines ?? 1,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        onSaved: onSaved,
        controller: controller,
      ),
    );
  }

  static InputDecoration inputDecoration(String label, IconData icon, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark 
        ? const Color(0xFF64B5F6) 
        : const Color(0xFF1E88E5);
    
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark 
          ? const Color(0xFF2C2C2C) 
          : Colors.grey[50],
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: primaryColor, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.red.shade300, width: 0.5),
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 8, right: 6),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.grey[800] 
              : primaryColor.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: primaryColor, size: 18),
      ),
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[300] : Colors.grey[700],
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: primaryColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ).copyWith(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 40,
      ),
    );
  }
}
