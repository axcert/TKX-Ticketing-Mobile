import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing_mobile/config/app_theme.dart';
import 'package:tkx_ticketing_mobile/widgets/custom_elevated_button.dart';
import 'package:tkx_ticketing_mobile/widgets/toast_message.dart';
import 'package:tkx_ticketing_mobile/providers/auth_provider.dart';
import 'package:tkx_ticketing_mobile/models/user.dart';

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
    _phoneNumberController.text = user.phone ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
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

                          // Phone Number Field
                          _buildTextField(
                            controller: _phoneNumberController,
                            label: '',
                            hint: 'Phone Number',
                            keyboardType: TextInputType.phone,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: CustomElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Handle save changes
                ToastMessage.success(context, 'Profile updated successfully');
              }
            },
            text: 'Save Changes',
          ),
        ),
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
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}
