import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/services/admindashboard_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mobileapplication/admindashboard/admindashboardpage/admindashboard_provider.dart';

class AdminSettingsPage extends StatefulWidget {
  const AdminSettingsPage({super.key});

  @override
  State<AdminSettingsPage> createState() => _AdminSettingsPageState();
}

class _AdminSettingsPageState extends State<AdminSettingsPage> {
  final AdminDashboardFirestore _dashboardFirestore = AdminDashboardFirestore();
  String _displayName = '';
  String? _photoUrl;
  String _email = '';
  String _lastLogin = '';
  bool _isLoading = true;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    try {
      final adminData = await _dashboardFirestore.getAdminData();
      if (mounted) {
        setState(() {
          _displayName = adminData['displayName'] ?? 'Admin';
          _photoUrl = adminData['photoURL'];
          _email = adminData['email'] ?? '';
          _lastLogin = _formatLastLogin(adminData['lastLogin']);
          _isOnline = adminData['isOnline'] ?? true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleOnlineStatus(bool value) async {
    try {
      await _dashboardFirestore.updateAdminOnlineStatus(value);
      if (mounted) {
        setState(() {
          _isOnline = value;
        });
        context.read<DashboardProvider>().updateOnlineStatus(value);
      }
    } catch (e) {
      // Handle error appropriately
    }
  }

  String _formatLastLogin(String? lastLogin) {
    if (lastLogin == null) return 'Today';
    try {
      final loginDate = DateTime.parse(lastLogin);
      final now = DateTime.now();
      final difference = now.difference(loginDate);

      if (difference.inDays == 0) {
        return 'Today, ${loginDate.hour}:${loginDate.minute.toString().padLeft(2, '0')} ${loginDate.hour >= 12 ? 'PM' : 'AM'}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return 'Today';
    }
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: const Color(0xFF1A237E)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
              ],
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Settings',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
          _buildSettingsCard(
            title: 'Profile Information',
            icon: Icons.person_outline,
            children: [
              Column(
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _photoUrl != null
                        ? NetworkImage(_photoUrl!)
                        : null,
                    child: _photoUrl == null
                        ? Icon(Icons.person, color: Colors.grey[700], size: 50)
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _displayName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(
                      Icons.access_time,
                      color: Colors.grey[600],
                    ),
                    title: const Text('Last Login'),
                    subtitle: Text(_lastLogin),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.circle,
                      color: _isOnline ? Colors.green : Colors.grey,
                    ),
                    title: const Text('Online Status'),
                    trailing: Switch(
                      value: _isOnline,
                      activeColor: Colors.green,
                      onChanged: _toggleOnlineStatus,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildSettingsCard(
            title: 'About',
            icon: Icons.info_outline,
            children: const [
              ListTile(
                title: Text('Version'),
                trailing: Text('1.0.0'),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleLogout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
