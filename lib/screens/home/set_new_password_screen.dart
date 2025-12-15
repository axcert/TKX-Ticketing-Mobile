import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/widgets/custom_elevated_button.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/toast_message.dart';
import '../../main.dart';

class SetNewPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const SetNewPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<SetNewPasswordScreen> createState() => _SetNewPasswordScreenState();
}

class _SetNewPasswordScreenState extends State<SetNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resetPassword(
        widget.email,
        widget.otp,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      if (mounted) {
        if (success) {
          ToastMessage.success(context, 'Password updated successfully');

          // Clear user data to force login with new password
          await authProvider.logout();

          if (mounted) {
            // Navigate to SplashToLoginWrapper which will show splash and then login screen
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const SplashToLoginWrapper(),
              ),
              (route) => false,
            );
          }
        } else {
          ToastMessage.error(
            context,
            authProvider.errorMessage ?? 'Failed to update password',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Change Password',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // Title
                    Text(
                      'Set a New Password',
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Create a strong password to protect your account.',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // New Password Field
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      enabled: !authProvider.isLoading,
                      decoration: InputDecoration(
                        hintText: 'New Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNewPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter new password';
                        }
                        if (value.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password Field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      enabled: !authProvider.isLoading,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',

                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 200),

                    // Update Password Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CustomElevatedButton(
                        text: "Update Password",
                        onPressed: _updatePassword,
                        isLoading: authProvider.isLoading,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
