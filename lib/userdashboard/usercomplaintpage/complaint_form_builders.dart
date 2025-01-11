import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/complaint_provider.dart';

class ComplaintFormBuilders {
  static Widget buildNameField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: _buildInputDecoration('Full Name', Icons.person, context),
        validator: (value) => value?.isEmpty ?? true 
            ? 'Please enter your name' 
            : (value!.length < 2 ? 'Name must be at least 2 characters' : null),
        onSaved: (value) => state.updateName(value ?? ''),
        textCapitalization: TextCapitalization.words,
      ),
    );
  }

  static Widget buildDateOfBirthField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: _buildInputDecoration('Date of Birth', Icons.calendar_today, context),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: Theme.of(context).brightness == Brightness.dark
                        ? const Color.fromARGB(255, 25, 135, 231)
                        : const Color(0xFF0277BD),
                  ),
                ),
                child: child!,
              );
            },
          );
          if (date != null) {
            state.updateDateOfBirth(date);
          }
        },
        validator: (value) => value?.isEmpty ?? true ? 'Please select your date of birth' : null,
        controller: TextEditingController(
          text: state.dateOfBirth != null
              ? DateFormat('MMMM dd, yyyy').format(state.dateOfBirth!)
              : '',
        ),
      ),
    );
  }

  static Widget buildPhoneField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: _buildInputDecoration('Phone Number', Icons.phone, context)
            .copyWith(hintText: '+63 XXX XXX XXXX'),
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your phone number';
          // Enhanced phone validation for international formats
          final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
          if (!phoneRegex.hasMatch(value!.replaceAll(RegExp(r'[\s-]'), ''))) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
        onSaved: (value) => state.updatePhone(value?.replaceAll(RegExp(r'[\s-]'), '') ?? ''),
        maxLength: 15,
        buildCounter: (context, {required currentLength, required maxLength, required isFocused}) => null,
      ),
    );
  }

  static Widget buildEmailField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: _buildInputDecoration('Email Address', Icons.email, context)
            .copyWith(hintText: 'example@email.com'),
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your email';
          // Enhanced email validation regex
          final emailRegex = RegExp(
            r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
            caseSensitive: false,
          );
          return !emailRegex.hasMatch(value!) 
              ? 'Please enter a valid email address' 
              : null;
        },
        onSaved: (value) => state.updateEmail(value ?? ''),
        maxLength: 100,
        buildCounter: (context, {required currentLength, required maxLength, required isFocused}) => null,
      ),
    );
  }

  static Widget buildAddressField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: _buildInputDecoration('Complete Address', Icons.location_on, context)
            .copyWith(
              alignLabelWithHint: true,
              hintText: 'Enter your complete address',
            ),
        maxLines: 3,
        validator: (value) => value?.isEmpty ?? true ? 'Please enter your address' : null,
        onSaved: (value) => state.updateAddress(value ?? ''),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  static Widget buildComplaintField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: _buildInputDecoration('Complaint Details', Icons.description, context)
            .copyWith(
              alignLabelWithHint: true,
              hintText: 'Please provide detailed information about your complaint...',
            ),
        maxLines: 5,
        maxLength: 1000,
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Please enter your complaint';
          if (value!.length < 20) return 'Please provide more details about your complaint (minimum 20 characters)';
          if (value.length > 1000) return 'Complaint is too long (maximum 1000 characters)';
          return null;
        },
        onSaved: (value) => state.updateComplaint(value?.trim() ?? ''),
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  static InputDecoration _buildInputDecoration(String label, IconData icon, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark 
        ? const Color.fromARGB(255, 25, 135, 231)
        : const Color(0xFF0277BD);

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: isDark
          ? Colors.grey[800]
          : const Color.fromARGB(255, 197, 212, 223).withOpacity(0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.grey[700]
              : primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: primaryColor,
          size: 22,
        ),
      ),
      labelStyle: TextStyle(
        color: isDark ? Colors.grey[300] : const Color(0xFF1A237E).withOpacity(0.7),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}