import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileapplication/services/cloudinary_service.dart';

class ComplaintFormProvider extends ChangeNotifier {
  // Form state
  final formKey = GlobalKey<FormState>();
  final picker = ImagePicker();
  
  // Form data
  String _name = '';
  DateTime? _dateOfBirth;
  String _phone = '';
  String _email = '';
  String _address = '';
  String _complaint = '';
  List<File> _attachedFiles = [];
  bool _showDateValidation = false;
  String? _message;
  bool _isError = false;

  // Getters
  String get name => _name;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get phone => _phone;
  String get email => _email;
  String get address => _address;
  String get complaint => _complaint;
  List<File> get attachedFiles => _attachedFiles;
  bool get showDateValidation => _showDateValidation;
  String? get message => _message;
  bool get isError => _isError;

  // Update methods
  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateDateOfBirth(DateTime? value) {
    _dateOfBirth = value;
    _showDateValidation = false;
    notifyListeners();
  }

  void updatePhone(String value) {
    _phone = value;
    notifyListeners();
  }

  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void updateAddress(String value) {
    _address = value;
    notifyListeners();
  }

  void updateComplaint(String value) {
    _complaint = value;
    notifyListeners();
  }

  // File handling
  void addFile(File file) {
    _attachedFiles.add(file);
    notifyListeners();
  }

  void removeFile(int index) {
    if (index >= 0 && index < _attachedFiles.length) {
      _attachedFiles.removeAt(index);
      notifyListeners();
    }
  }

  // Form actions
  void clearForm() {
    _name = '';
    _dateOfBirth = null;
    _phone = '';
    _email = '';
    _address = '';
    _complaint = '';
    _attachedFiles.clear();
    _showDateValidation = false;
    _message = null;
    _isError = false;
    notifyListeners();
  }

  // Validation methods
  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Form submission
  Future<bool> submitForm(BuildContext context) async {
    _showDateValidation = true;
    notifyListeners();

    if (!_validateForm(context)) return false;

    try {
      List<String> fileUrls = await _uploadFiles();
      await _saveComplaint(fileUrls);
      _showSuccessMessage(context);
      clearForm();
      return true;
    } catch (e) {
      _showErrorMessage(context, e.toString());
      return false;
    }
  }

  // Private helper methods
  bool _validateForm(BuildContext context) {
    if (!formKey.currentState!.validate()) return false;
    if (_dateOfBirth == null || calculateAge(_dateOfBirth!) < 18) {
      _showAgeValidationError(context);
      return false;
    }
    return true;
  }

  Future<List<String>> _uploadFiles() async {
    if (_attachedFiles.isEmpty) return [];
    return await CloudinaryService.uploadFiles(_attachedFiles, 'complaints');
  }

  Future<void> _saveComplaint(List<String> fileUrls) async {
    formKey.currentState!.save();
    // Add your backend save logic here
  }

  void _showSuccessMessage(BuildContext context) {
    _message = 'Complaint submitted successfully';
    _isError = false;
    notifyListeners();
  }

  void _showErrorMessage(BuildContext context, String error) {
    _message = 'Error submitting complaint: $error';
    _isError = true;
    notifyListeners();
  }

  void _showAgeValidationError(BuildContext context) {
    _message = 'You must be at least 18 years old';
    _isError = true;
    notifyListeners();
  }
}
