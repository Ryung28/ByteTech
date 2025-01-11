import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobileapplication/admindashboard/edituserpage/edituser_page.dart';
import 'package:mobileapplication/admindashboard/usermanagementpage/reusable_usermanagement.dart';
import 'package:mobileapplication/models/usermanagementmodel.dart';


const Color deepBlue = Color(0xFF144DD9);

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ManageUserPageState createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<List<UserModel>> _users;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _users = fetchUsers();
  }

  Future<List<UserModel>> fetchUsers() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return UserModel.fromMap({...data, 'id': doc.id});
    }).toList();
  }

  void navigateToEditUser(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserPage(user: user)),
    ).then((_) {
      setState(() {
        _users = fetchUsers();
      });
    });
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      return user.firstName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.lastName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.username.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            UserManagementWidgets.buildHeader(context, "User Management"),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 280,
                  height: 40,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: deepBlue, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) => setState(() => _searchQuery = value),
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search users...',
                                hintStyle: TextStyle(fontSize: 14),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 0),
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchQuery.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'User Management',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: deepBlue,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Manage all system users',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 20),
                              FutureBuilder<List<UserModel>>(
                                future: _users,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return UserManagementWidgets.buildLoadingState();
                                  }
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text(
                                        "Error: ${snapshot.error}",
                                        style: TextStyle(color: Colors.red[400]),
                                      ),
                                    );
                                  }
                                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                                    return UserManagementWidgets.buildEmptyState();
                                  }
                                  return UserManagementWidgets.buildUserTable(
                                    _filterUsers(snapshot.data!),
                                    navigateToEditUser,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditUserPage()),
            ).then((_) {
              setState(() {
                _users = fetchUsers();
              });
            });
          },
          backgroundColor: deepBlue,
          icon: Icon(Icons.person_add_rounded, color: Colors.white),
          label: Text(
            "Add User",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          elevation: 4,
        ),
      ),
    );
  }
}

