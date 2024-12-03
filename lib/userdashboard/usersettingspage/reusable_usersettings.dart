import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettingsWidgets {
  static Widget buildSettingsSection({
    required String title,
    required List<Widget> items,
    required Color deepBlue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: deepBlue,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: items),
        ),
      ],
    );
  }

  static Widget buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color deepBlue,
    Color? iconColor,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? deepBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? deepBlue),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.chevron_right, color: deepBlue),
      onTap: onTap,
    );
  }

  static Widget buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () async {
          try {
            final user = FirebaseAuth.instance.currentUser;

            if (user != null) {
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .delete();
            }

            if (user != null) {
              try {
                final storageRef = FirebaseStorage.instance
                    .ref()
                    .child('profile_pictures/${user.uid}');
                await storageRef.delete();
              } catch (e) {}
            }

            // Sign out from Firebase
            await FirebaseAuth.instance.signOut();

            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/LoginPage',
                (Route<dynamic> route) => false,
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error signing out: ${e.toString()}')),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade400,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Logout',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  static Widget buildProfileHeader({
    required String username,
    required String? email,
    required String? profilePicture,
    required VoidCallback onImageTap,
    required Color deepBlue,
    required Color whiteWater,
    required Color lightBlue,
  }) {
    return FlexibleSpaceBar(
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [deepBlue, deepBlue.withOpacity(0.8)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: WavePainter(lightBlue.withOpacity(0.1)),
                size: const Size(double.infinity, 80),
              ),
            ),
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildProfileImage(
                      profilePicture: profilePicture,
                      onTap: onImageTap,
                      deepBlue: deepBlue,
                      whiteWater: whiteWater,
                    ),
                    const SizedBox(height: 16),
                    buildProfileText(
                      username: username,
                      email: email,
                      whiteWater: whiteWater,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildProfileImage({
    required String? profilePicture,
    required VoidCallback onTap,
    required Color deepBlue,
    required Color whiteWater,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 65,
            backgroundColor: whiteWater,
            backgroundImage: (profilePicture != null && profilePicture.isNotEmpty)
                ? NetworkImage(profilePicture)
                : null,
            child: (profilePicture == null || profilePicture.isEmpty)
                ? Icon(Icons.person, size: 65, color: deepBlue)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: buildCameraButton(
              onTap: onTap, deepBlue: deepBlue, whiteWater: whiteWater),
        ),
      ],
    );
  }

  static Widget buildCameraButton({
    required VoidCallback onTap,
    required Color deepBlue,
    required Color whiteWater,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: whiteWater,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
            ),
          ],
        ),
        child: Icon(Icons.camera_alt, size: 20, color: deepBlue),
      ),
    );
  }

  static Widget buildProfileText({
    required String username,
    required String? email,
    required Color whiteWater,
  }) {
    return Column(
      children: [
        Text(
          username,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        Text(
          email ?? '',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: whiteWater.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  static Future<void> setPersistence() async {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);

      // Enable offline persistence for Firestore
      await FirebaseFirestore.instance.enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      );
    } catch (e) {
      print('Error setting persistence: $e');
    }
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.7,
      size.width * 0.5,
      size.height * 0.8,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.9,
      size.width,
      size.height * 0.8,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
