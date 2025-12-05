import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/models/user_model.dart';
import 'dart:io';
import 'package:tkx_ticketing/providers/auth_provider.dart';
import 'package:tkx_ticketing/widgets/custom_elevated_button.dart';
import 'package:tkx_ticketing/widgets/toast_message.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = true;
  String? _pickedImage; // Local file path when user picks a new image

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
    _phoneNumberController.text = user.phone ?? '';
    _pickedImage = null; // Clear any previously picked image

    print('📸 Populating fields - Profile Photo: ${user.profilePhoto}');
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _pickedImage = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ToastMessage.error(context, 'Failed to pick image: ${e.toString()}');
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveChanges() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        profileImage: _pickedImage, // Only send if user picked a new image
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
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
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
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey.shade200,
                                  ),
                                  child: ClipOval(
                                    child: _buildProfileImage(user),
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
                          ),

                          const SizedBox(height: 16),

                          // User Name (first_name + last_name from api)
                          Text(
                            '${user?.fullName}',
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(fontWeight: FontWeight.w700),
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

                          _buildTextField(
                            controller: _phoneNumberController,
                            label: '',
                            hint: 'Telephone',
                            keyboardType: TextInputType.phone,
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

  Widget _buildProfileImage(User? user) {
    // 1. Check if user picked a new image locally
    if (_pickedImage != null) {
      final file = File(_pickedImage!);
      if (file.existsSync()) {
        return Image.file(file, fit: BoxFit.cover);
      }
    }

    // 2. Check if user has a profile photo URL from API
    if (user?.profilePhoto != null && user!.profilePhoto!.isNotEmpty) {
      return Image.network(
        user.profilePhoto!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, ___) =>
            const Icon(Icons.person, size: 60, color: Colors.grey),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(child: CircularProgressIndicator());
        },
      );
    }

    // 3. Default fallback
    return const Icon(Icons.person, size: 60, color: Colors.grey);
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
        ),
      ],
    );
  }
}
