import 'package:flutter/material.dart';
import 'package:mobileapplication/admindashboard/edituserpage/edituser_firebase.dart';
import 'package:mobileapplication/models/usermanagementmodel.dart';
import 'package:mobileapplication/admindashboard/edituserpage/reusable_edituser.dart';
import 'package:mobileapplication/reusable_widget/bottom_nav_bar.dart';

class EditUserPage extends StatefulWidget {
  final UserModel? user;
  const EditUserPage({super.key, this.user});

  @override
  // ignore: library_private_types_in_public_api
  _EditUserPageState createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late bool _isAdmin;
  bool _isLoading = false;
  bool _obscurePassword = true;
  int currentIndex = 1;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user?.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user?.lastName ?? '');
    _usernameController = TextEditingController(text: widget.user?.username ?? '');
    _emailController = TextEditingController(text: widget.user?.email ?? '');
    _passwordController = TextEditingController();
    _isAdmin = widget.user?.isAdmin ?? false;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      if (widget.user == null) {
        // Create new user
        await _userService.createUser(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          isAdmin: _isAdmin,
        );
      } else {
        // Update existing user
        await _userService.updateUser(
          userId: widget.user?.id ?? '',
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          username: _usernameController.text,
          email: _emailController.text,
          isAdmin: _isAdmin,
          password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user == null ? 'User created successfully!' : 'User updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        extendBody: true,
        backgroundColor: Color(0xFFE3F2FD),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  EditUserWidgets.buildHeader(context, widget.user),
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            spreadRadius: 5,
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              EditUserWidgets.buildInputField(
                                controller: _firstNameController,
                                label: 'First Name',
                                icon: Icons.person_outline,
                              ),
                              SizedBox(height: 20),
                              EditUserWidgets.buildInputField(
                                controller: _lastNameController,
                                label: 'Last Name',
                                icon: Icons.person_outline,
                              ),
                              SizedBox(height: 20),
                              EditUserWidgets.buildInputField(
                                controller: _usernameController,
                                label: 'Username',
                                icon: Icons.account_circle_outlined,
                              ),
                              SizedBox(height: 20),
                              EditUserWidgets.buildInputField(
                                controller: _emailController,
                                label: 'Email',
                                icon: Icons.email_outlined,
                              ),
                              SizedBox(height: 20),
                              EditUserWidgets.buildInputField(
                                controller: _passwordController,
                                label: widget.user == null ? 'Password' : 'New Password (optional)',
                                icon: Icons.lock_outline,
                                isPassword: true,
                                obscureText: _obscurePassword,
                                onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
                                isOptional: widget.user != null,
                              ),
                              SizedBox(height: 20),
                              EditUserWidgets.buildAdminSwitch(
                                value: _isAdmin,
                                onChanged: (value) => setState(() => _isAdmin = value),
                              ),
                              SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: _isLoading
                                    ? null
                                    : () => _handleSave(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF1976D2),
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 5,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        widget.user == null
                                            ? 'Add User'
                                            : 'Save Changes',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: FloatingNavBar(
          currentIndex: currentIndex,
          backgroundColor: Colors.transparent,
          isAdmin: true,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
