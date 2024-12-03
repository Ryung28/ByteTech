import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileapplication/authenticationpages/authentication_pages/signin_page.dart';
import 'package:mobileapplication/providers/theme_provider.dart';
import 'package:mobileapplication/reusable_widget/bottom_nav_bar.dart';
import 'package:mobileapplication/services/cloudinary_service.dart';
import 'dart:io';
import 'package:mobileapplication/userdashboard/usersettingspage/reusable_usersettings.dart';
import 'package:mobileapplication/userdashboard/usersettingspage/usersettings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:mobileapplication/config/theme_config.dart';

class UsersettingsPage extends StatefulWidget {
  const UsersettingsPage({super.key});

  @override
  _UsersettingsPageState createState() => _UsersettingsPageState();
}

class _UsersettingsPageState extends State<UsersettingsPage> {
  final ImagePicker _picker = ImagePicker();
  SettingsProvider? _settingsProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      _settingsProvider?.loadUserData();
    });
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading image...')),
        );

        final imageUrl = await CloudinaryService.uploadFile(
          imageFile,
          'profile_pictures'
        );

        await _settingsProvider!.updateProfilePicture(imageUrl);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAboutApp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About App'),
        content: const Text(
            'Marine Guard - Version 1.0.0\n\nAn application designed to protect and preserve marine life.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms & Conditions'),
        content: const SingleChildScrollView(
          child: Text('Your terms and conditions text here...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text('Your privacy policy text here...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarBrightness: Theme.of(context).brightness,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      // Set system navigation bar color
      systemNavigationBarColor: isDark 
          ? ThemeConfig.darkBackground  // Deep blue background
          : Provider.of<SettingsProvider>(context).whiteWater,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: isDark 
            ? ThemeConfig.darkBackground  // Deep blue background
            : Provider.of<SettingsProvider>(context).whiteWater,
        extendBody: true,
        body: Consumer<SettingsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? ThemeConfig.darkBlueAccent : provider.deepBlue
                  ),
                ),
              );
            }

            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: isDark ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        ThemeConfig.darkBackground,  // Deep blue background
                        ThemeConfig.darkSurface,    // Slightly lighter blue
                      ],
                    ) : null,
                  ),
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 300,
                        floating: false,
                        pinned: true,
                        backgroundColor: isDark 
                            ? ThemeConfig.darkBackground  // Deep blue background
                            : provider.deepBlue,
                        automaticallyImplyLeading: false,
                        leading: IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: isDark 
                                ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                : Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        flexibleSpace: UserSettingsWidgets.buildProfileHeader(
                          username: provider.username,
                          email: provider.email,
                          profilePicture: provider.profilePictureUrl,
                          onImageTap: _pickImage,
                          deepBlue: isDark 
                              ? ThemeConfig.darkBlueAccent  // Glowing blue color
                              : provider.deepBlue,
                          whiteWater: isDark 
                              ? ThemeConfig.darkBackground  // Deep blue background
                              : Provider.of<SettingsProvider>(context).whiteWater,
                          lightBlue: isDark 
                              ? ThemeConfig.darkSurface  // Slightly lighter blue
                              : provider.lightBlue,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark 
                                ? ThemeConfig.darkBackground.withOpacity(0.95)  // Slightly transparent
                                : provider.whiteWater,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                              right: 16,
                              top: 16,
                              bottom: 100,  // Added padding for bottom nav bar
                            ),
                            child: Column(
                              children: [
                                UserSettingsWidgets.buildSettingsSection(
                                  title: 'Account Settings',
                                  items: [
                                    UserSettingsWidgets.buildSettingsTile(
                                      icon: Icons.lock_outline,
                                      title: 'Change Password',
                                      subtitle: 'Update your password',
                                      onTap: _changePassword,
                                      deepBlue: isDark 
                                          ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                          : provider.deepBlue,
                                      color: isDark 
                                          ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                          : provider.deepBlue,
                                    ),
                                    buildThemeToggle(context),
                                  ],
                                  deepBlue: isDark 
                                      ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                      : provider.deepBlue,
                                ),
                                UserSettingsWidgets.buildSettingsSection(
                                  title: 'Information',
                                  items: [
                                    UserSettingsWidgets.buildSettingsTile(
                                      icon: Icons.info_outline,
                                      title: 'About Marine Guard',
                                      subtitle: 'Learn more about the app',
                                      onTap: _showAboutApp,
                                      deepBlue: isDark 
                                          ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                          : provider.deepBlue,
                                      color: isDark 
                                          ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                          : provider.deepBlue,
                                    ),
                                    UserSettingsWidgets.buildSettingsTile(
                                      icon: Icons.description_outlined,
                                      title: 'Terms & Conditions',
                                      subtitle: 'Read our terms of service',
                                      onTap: _showTermsAndConditions,
                                      deepBlue: isDark 
                                          ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                          : provider.deepBlue,
                                      color: isDark 
                                          ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                          : provider.deepBlue,
                                    ),
                                    UserSettingsWidgets.buildSettingsTile(
                                      icon: Icons.privacy_tip_outlined,
                                      title: 'Privacy Policy',
                                      subtitle: 'View our privacy policy',
                                      onTap: _showPrivacyPolicy,
                                      deepBlue: isDark 
                                          ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                          : provider.deepBlue,
                                      color: isDark 
                                          ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                          : provider.deepBlue,
                                    ),
                                  ],
                                  deepBlue: isDark 
                                      ? ThemeConfig.darkBlueAccent  // Glowing blue color
                                      : provider.deepBlue,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    minimumSize: const Size(double.infinity, 50),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Confirm Logout'),
                                          content: const Text(
                                              'Are you sure you want to logout?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context); // Close dialog
                                                _signOut(); // Call the existing signOut method
                                              },
                                              child: const Text('Logout',
                                                  style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isDark ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          ThemeConfig.darkBackground.withOpacity(0),
                          ThemeConfig.darkBackground,
                        ],
                      ) : null,
                    ),
                    child: FloatingNavBar(
                      currentIndex: 3,
                      backgroundColor: isDark 
                          ? ThemeConfig.darkBackground
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    try {
      final email = _auth.currentUser?.email;
      if (email != null) {
        await _auth.sendPasswordResetEmail(email: email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final googleSignIn = GoogleSignIn(
        scopes: ['email', 'profile'],
        signInOption: SignInOption.standard,
      );
      
      try {
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (e) {
        print('Google Sign In error: $e');
      }
      
      await FirebaseAuth.instance.signOut();
      
      if (!mounted) return;

      // Navigate to sign in page and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MySignin()),
        (route) => false,
      );
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: $e')),
      );
    }
  }

  Widget buildThemeToggle(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeConfig.darkBackground
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: Theme.of(context).brightness == Brightness.dark 
            ? []
            : [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
      ),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark 
                    ? ThemeConfig.darkBlueAccent.withOpacity(0.1)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: isDark 
                    ? ThemeConfig.darkBlueAccent
                    : Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            title: Text(
              'Dark Mode',
              style: TextStyle(
                color: isDark 
                    ? ThemeConfig.darkBlueAccent
                    : Theme.of(context).colorScheme.onBackground,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Switch.adaptive(
              value: themeProvider.isDarkMode,
              onChanged: (_) => themeProvider.toggleTheme(),
              activeColor: isDark 
                  ? ThemeConfig.darkBlueAccent 
                  : Theme.of(context).colorScheme.primary,
              activeTrackColor: isDark 
                  ? ThemeConfig.darkBlueAccent.withOpacity(0.3)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          );
        },
      ),
    );
  }

  Widget buildImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, size: 50, color: Colors.white),
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, __) {},
      child: imageUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
    );
  }
}
