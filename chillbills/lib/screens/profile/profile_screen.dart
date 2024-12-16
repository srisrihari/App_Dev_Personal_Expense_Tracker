import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../screens/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF6A5AE0),
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;

          if (user == null) {
            return const Center(child: Text('Please log in'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // User Profile Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: user.photoUrl != null 
                              ? NetworkImage(user.photoUrl!) 
                              : null,
                            child: user.photoUrl == null 
                              ? Icon(
                                  Icons.person, 
                                  size: 50, 
                                  color: Colors.grey[600]
                                )
                              : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            user.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.email ?? 'No email',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Profile Actions
                  _buildProfileAction(
                    context,
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    onTap: () {
                      // TODO: Implement edit profile
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit profile coming soon!')),
                      );
                    },
                  ),

                  _buildProfileAction(
                    context,
                    icon: Icons.security,
                    title: 'Change Password',
                    onTap: () {
                      // TODO: Implement change password
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change password coming soon!')),
                      );
                    },
                  ),

                  _buildProfileAction(
                    context,
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {
                      authProvider.logout();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileAction(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6A5AE0)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
