import 'package:flutter/material.dart';
import 'package:mobile_app/config/app_theme.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/event_provider.dart';
import 'package:mobile_app/main.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        children: [
          DrawerHeader(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.border,
                  backgroundImage: const AssetImage(
                    'assets/profile_placeholder.png',
                  ),
                  onBackgroundImageError: (exception, stackTrace) {},
                  child: const Icon(Icons.person, size: 30, color: Colors.grey),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${authProvider.user?.fullName}',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${authProvider.user?.email}',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // General Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'General',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          const SizedBox(height: 8),
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
            subtitle: 'Customize how your scanner responds',
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
            onTap: () async {
              // Show confirmation dialog
              await showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Close the confirmation dialog
                        Navigator.pop(dialogContext);

                        if (!context.mounted) return;

                        // Close the drawer
                        // Navigator.pop(context);

                        if (!context.mounted) return;

                        // Show loading dialog
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) =>
                              const Center(child: CircularProgressIndicator()),
                        );

                        try {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final eventProvider = Provider.of<EventProvider>(
                            context,
                            listen: false,
                          );

                          // Call logout API and clear local data
                          await authProvider.logout();

                          // Clear event data
                          eventProvider.clearEvents();

                          if (!context.mounted) return;

                          // Close loading dialog
                          Navigator.of(context, rootNavigator: true).pop();

                          if (!context.mounted) return;

                          // Navigate to SplashToLoginWrapper which will show login screen
                          Navigator.of(
                            context,
                            rootNavigator: true,
                          ).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const SplashToLoginWrapper(),
                            ),
                            (route) => false,
                          );
                        } catch (e) {
                          // Close loading dialog on error
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Logout failed: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
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
    return ListTile(
      onTap: onTap,

      leading:
          // Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),

      // Title and Subtitle
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontSize: 13),
          ),
        ],
      ),
      trailing: Icon(Icons.chevron_right, color: AppColors.border, size: 24),
    );
  }
}
