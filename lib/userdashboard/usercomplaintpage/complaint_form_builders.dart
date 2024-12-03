import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobileapplication/userdashboard/usercomplaintpage/complaint_provider.dart';

class ComplaintFormBuilders {
  static Widget buildNameField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: inputDecoration('Full Name', Icons.person, context),
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter your name' : null,
        onSaved: (value) => state.updateName(value ?? ''),
      ),
    );
  }

  static Widget buildDateOfBirthField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: inputDecoration('Date of Birth', Icons.calendar_today, context),
        readOnly: true,
        onTap: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (date != null) {
            state.updateDateOfBirth(date);
          }
        },
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please select your date of birth' : null,
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
        decoration: inputDecoration('Phone Number', Icons.phone, context),
        keyboardType: TextInputType.phone,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter your phone number' : null,
        onSaved: (value) => state.updatePhone(value ?? ''),
      ),
    );
  }

  static Widget buildEmailField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: inputDecoration('Email Address', Icons.email, context),
        keyboardType: TextInputType.emailAddress,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter your email' : null,
        onSaved: (value) => state.updateEmail(value ?? ''),
      ),
    );
  }

  static Widget buildAddressField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: inputDecoration('Complete Address', Icons.location_on, context),
        maxLines: 3,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter your address' : null,
        onSaved: (value) => state.updateAddress(value ?? ''),
      ),
    );
  }

  static Widget buildComplaintField(BuildContext context, ComplaintFormProvider state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: inputDecoration('Complaint Details', Icons.description, context)
            .copyWith(
          alignLabelWithHint: true,
          hintText: 'Please provide detailed information about your complaint...',
        ),
        maxLines: 5,
        validator: (value) =>
            value?.isEmpty ?? true ? 'Please enter your complaint' : null,
        onSaved: (value) => state.updateComplaint(value ?? ''),
      ),
    );
  }

  static InputDecoration inputDecoration(
      String label, IconData icon, BuildContext context) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).brightness == Brightness.dark
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
        borderSide: BorderSide(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 25, 135, 231)
              : const Color(0xFF0277BD),
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.red.shade300, width: 1),
      ),
      prefixIcon: Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[700]
              : const Color(0xFF0277BD).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 25, 135, 231)
              : const Color(0xFF0277BD),
          size: 22,
        ),
      ),
      labelStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[300]
            : const Color(0xFF1A237E).withOpacity(0.7),
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color.fromARGB(255, 25, 135, 231)
            : const Color(0xFF0277BD),
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ).copyWith(
      constraints: const BoxConstraints(minHeight: 60),
    );
  }
} 