import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // User Profile Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Profile Image
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: const AssetImage('assets/profile_placeholder.png'),
                    onBackgroundImageError: (exception, stackTrace) {},
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ismael Krohn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ismaelkrohn@gamil.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // General Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'General',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),

            // Edit Profile
            _buildMenuItem(
              context: context,
              icon: Icons.person_outline,
              iconColor: const Color(0xFF5B8DEE),
              iconBgColor: const Color(0xFFE3EDFF),
              title: 'Edit Profile',
              subtitle: 'Edit your information',
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
              },
            ),

            // Change Password
            _buildMenuItem(
              context: context,
              icon: Icons.lock_outline,
              iconColor: const Color(0xFF5B8DEE),
              iconBgColor: const Color(0xFFE3EDFF),
              title: 'Change Password',
              subtitle: 'Change Password',
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),

            // Scanner Preferences
            _buildMenuItem(
              context: context,
              icon: Icons.settings_outlined,
              iconColor: const Color(0xFF5B8DEE),
              iconBgColor: const Color(0xFFE3EDFF),
              title: 'Scanner Preferences',
              subtitle: 'Customize how your scanner\nresponds',
              onTap: () {
                // Navigate to Scanner Preferences
              },
            ),

            const SizedBox(height: 16),

            // Preferences Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Preferences',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),

            // Log Out
            _buildMenuItem(
              context: context,
              icon: Icons.logout,
              iconColor: const Color(0xFFE53935),
              iconBgColor: const Color(0xFFFFEBEE),
              title: 'Log Out',
              subtitle: 'Logout from app',
              onTap: () {
                // Handle logout
              },
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            // Title and Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow Icon
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
