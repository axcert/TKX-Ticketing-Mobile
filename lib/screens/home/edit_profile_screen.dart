import 'package:flutter/material.dart';
import 'package:mobile_app/models/user.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/config/app_theme.dart';
import 'package:mobile_app/widgets/custom_elevated_button.dart';
import 'package:mobile_app/widgets/toast_message.dart';
import 'package:mobile_app/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user != null) {
      // User data already available from AuthProvider
      _populateFields(authProvider.user!);
      setState(() {
        _isLoading = false;
      });
    } else {
      // Fetch user profile from API
      await authProvider.checkAuthStatus();
      if (mounted && authProvider.user != null) {
        _populateFields(authProvider.user!);
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _populateFields(User user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      if (mounted) {
        if (success) {
          // Show success message from backend
          final message =
              authProvider.successMessage ?? 'Profile updated successfully';
          ToastMessage.success(context, message);

          // Navigate back after successful update
          Navigator.pop(context);
        } else if (authProvider.errorMessage != null) {
          // Show error message from backend
          ToastMessage.error(context, authProvider.errorMessage!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                final user = authProvider.user;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Profile Image
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade200,
                                ),
                                child: ClipOval(
                                  child: Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // User Name (first_name + last_name from api)
                          Text(
                            '${user?.fullName}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),

                          // Email (from api)
                          Text(
                            user?.email ?? '',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(color: AppColors.textSecondary),
                          ),

                          const SizedBox(height: 40),

                          // First Name Field
                          _buildTextField(
                            controller: _firstNameController,
                            label: '',
                            hint: 'First Name',
                          ),

                          const SizedBox(height: 10),

                          // Last Name Field
                          _buildTextField(
                            controller: _lastNameController,
                            label: '',
                            hint: 'Last Name',
                          ),

                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return BottomAppBar(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: CustomElevatedButton(
                onPressed: _handleSaveChanges,
                text: 'Save Changes',
                isLoading: authProvider.isLoading,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[Text(label), const SizedBox(height: 8)],
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hint),
          // validator: (value) {
          //   if (value == null || value.isEmpty) {
          //     return 'This field is required';
          //   }
          //   return null;
          // },
        ),
      ],
    );
  }
}
