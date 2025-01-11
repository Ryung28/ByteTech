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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
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

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? ThemeConfig.darkBackground
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark ? ThemeConfig.darkBlueAccent : _settingsProvider?.deepBlue ?? Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: isDark ? ThemeConfig.darkBlueAccent : _settingsProvider?.deepBlue,
                  ),
                ),
                title: Text(
                  'Take a photo',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (isDark ? ThemeConfig.darkBlueAccent : _settingsProvider?.deepBlue ?? Colors.blue).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: isDark ? ThemeConfig.darkBlueAccent : _settingsProvider?.deepBlue,
                  ),
                ),
                title: Text(
                  'Choose from gallery',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
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
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A237E)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Terms & Conditions',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrivacySection(
                  'Last Updated: December 2024',
                  isDate: true,
                  context: context,
                ),
                const SizedBox(height: 16),
                _buildPrivacySection(
                  '1. Acceptance of Terms',
                  content: [
                    'By accessing and using Marine Guard, you agree to be bound by these terms and conditions. If you disagree with any part of these terms, you may not access the application.',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  '2. User Responsibilities',
                  content: [
                    'You must provide accurate and complete information when creating an account',
                    'You are responsible for maintaining the confidentiality of your account',
                    'You agree to use the app in compliance with local fishing and marine protection laws',
                    'You must not use the app for any illegal or unauthorized purpose',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  '3. Ban Period Compliance',
                  content: [
                    'You agree to respect and comply with all fishing ban periods',
                    'You acknowledge that ban periods are enforced to protect marine life',
                    'Violation of ban periods may result in account suspension',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  '4. Privacy & Data',
                  content: [
                    'We collect and process your data as described in our Privacy Policy',
                    'Your location data may be used to provide relevant marine information',
                    'We may share aggregated, non-personal data for research purposes',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  '5. Modifications',
                  content: [
                    'We reserve the right to modify these terms at any time. We will notify users of any changes through the app.',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  '6. Disclaimer',
                  content: [
                    'Marine Guard is provided "as is" without any warranties. We do not guarantee the accuracy of marine data or weather information.',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  '7. Contact',
                  content: [
                    'Email: marineguard.ph@gmail.com',
                    'Website: https://marineguard-admin.website/',
                    'Address: Marine Guard Team',
                  ],
                  context: context,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1A237E)
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : const Color(0xFF1A237E),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 500),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPrivacySection(
                  'Last Updated: December 2024',
                  isDate: true,
                  context: context,
                ),
                const SizedBox(height: 16),
                _buildPrivacySection(
                  'Information We Collect',
                  content: [
                    'Personal Information (name, email, profile picture)',
                    'Location Data for marine conditions',
                    'Device information and app usage statistics',
                    'Fishing activity and ban period compliance data',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  'How We Use Your Information',
                  content: [
                    'Provide marine protection services and updates',
                    'Monitor and enforce ban period compliance',
                    'Improve app features and user experience',
                    'Send important notifications about marine conditions',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  'Data Security',
                  content: [
                    'End-to-end encryption for personal data',
                    'Regular security audits and updates',
                    'Secure cloud storage with Firebase',
                    'Limited employee access to user data',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  'Information Sharing',
                  content: [
                    'We never sell your personal information',
                    'Data may be shared with marine protection authorities',
                    'Anonymous analytics for app improvement',
                    'Third-party service providers (storage, analytics)',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  'Your Rights',
                  content: [
                    'Access your personal data',
                    'Request data correction or deletion',
                    'Opt-out of non-essential communications',
                    'Data portability options',
                  ],
                  context: context,
                ),
                _buildPrivacySection(
                  'Contact Us',
                  content: [
                    'Email: marineguard.ph@gmail.com',
                    'Website: https://marineguard-admin.website/',
                    'Address: Marine Guard Team',
                  ],
                  context: context,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1A237E),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFullScreenProfile(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return;
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullScreenProfileView(
          imageUrl: imageUrl,
          username: _settingsProvider?.username ?? '',
        ),
      ),
    );
  }


  Widget _buildPrivacySection(
    String title, {
    List<String>? content,
    bool isDate = false,
    required BuildContext context,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.1)
            : const Color(0xFF1A237E).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1A237E),
              fontWeight: isDate ? FontWeight.normal : FontWeight.bold,
              fontSize: isDate ? 14 : 18,
              fontStyle: isDate ? FontStyle.italic : FontStyle.normal,
            ),
          ),
          if (content != null) ...[
            const SizedBox(height: 8),
            ...content.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF1A237E),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
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
                          onImageTap: () => _showFullScreenProfile(provider.profilePictureUrl),
                          onCameraTap: _showImageSourceSelection,
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
                                      context: context,
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
                                      context: context,
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
                                      context: context,
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
                                      context: context,
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
      onBackgroundImageError: (_, __) {} ,
      child: imageUrl.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white) : null,
    );
  }
}

class FullScreenProfileView extends StatelessWidget {
  final String imageUrl;
  final String username;

  const FullScreenProfileView({
    Key? key,
    required this.imageUrl,
    required this.username,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? ThemeConfig.darkBackground : Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          username,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Hero(
          tag: 'profile-$imageUrl',
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDark ? ThemeConfig.darkBlueAccent : Colors.white,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Error loading image',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
