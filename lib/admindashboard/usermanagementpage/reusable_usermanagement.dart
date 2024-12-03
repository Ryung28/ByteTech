import 'package:flutter/material.dart';
import 'package:mobileapplication/models/usermanagementmodel.dart';

class UserManagementWidgets {
  static Widget buildHeader(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget buildEmptyState() {
    return const Center(
      child: Text('No users found'),
    );
  }

  static Widget buildUserTable(
    List<UserModel> users,
    Function(UserModel) onEdit,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final user = users[index];
        String initials = _getInitials(user.firstName, user.lastName);
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text('${user.firstName} ${user.lastName}'),
          subtitle: Text(user.email),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => onEdit(user),
          ),
        );
      },
    );
  }

  static String _getInitials(String firstName, String lastName) {
    String firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    String lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }
}