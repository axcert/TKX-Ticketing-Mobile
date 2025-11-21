import 'package:flutter/material.dart';
import 'package:mobile_app/config/app_theme.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/event_provider.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/widgets/showpreferences_dialog_box.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({super.key});

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool _vibrateOnScan = true;
    bool _beepOnScan = false;
    bool _autoCheckIn = false;
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
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppColors.textHint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Edit Profile
          _buildMenuItem(
            context: context,
            icon: Icons.person_outline,

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
            title: 'Scanner Preferences',
            subtitle: 'Customize how your scanner responds',
            onTap: () {
              ShowPreferencesDialogBox.show(
                context,

                onPreferencesChanged: (vibrateOnScan, beepOnScan, autoCheckIn) {
                  authProvider.updateUserPreferences(
                    isVibrate: vibrateOnScan,
                    isBeep: beepOnScan,
                    isAutoCheckIn: autoCheckIn,
                  );
                },
              );
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
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: AppColors.textHint,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Log Out
          _buildMenuItem(
            context: context,
            icon: Icons.logout,
            iconColor: AppColors.error,
            iconBgColor: AppColors.error.withOpacity(0.3),
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
                              builder: (context) =>
                                  const SplashToLoginWrapper(),
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
                                backgroundColor: AppColors.error,
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
    Color? iconColor,
    Color? iconBgColor,
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
              color: iconBgColor ?? AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 24),
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
