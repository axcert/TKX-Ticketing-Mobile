import 'package:flutter/material.dart';
import 'login_bottom_sheet.dart';
import '../../../widgets/custom_elevated_button.dart';

class SetNewPasswordBottomSheet extends StatefulWidget {
  const SetNewPasswordBottomSheet({super.key});

  static void show(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 600),
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: const SetNewPasswordBottomSheet(),
          ),
        );
      },
    );
  }

  @override
  State<SetNewPasswordBottomSheet> createState() =>
      _SetNewPasswordBottomSheetState();
}

class _SetNewPasswordBottomSheetState extends State<SetNewPasswordBottomSheet> {
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

  void _handleUpdatePassword() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully!')),
      );
      Navigator.pop(context);
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          showGeneralDialog(
            context: context,
            barrierDismissible: false,
            barrierLabel: '',
            barrierColor: Colors.transparent,
            transitionDuration: const Duration(milliseconds: 600),
            pageBuilder: (context, animation1, animation2) {
              return const SizedBox.shrink();
            },
            transitionBuilder: (context, animation, secondaryAnimation, child) {
              return Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      ),
                  child: const LoginBottomSheet(),
                ),
              );
            },
          );
        }
      });
    }
  }

  void _handleBackToLogin() {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: '',
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation1, animation2) {
            return const SizedBox.shrink();
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: const LoginBottomSheet(),
              ),
            );
          },
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLogo(),
                  const SizedBox(height: 32),
                  _buildTitle(),
                  const SizedBox(height: 8),
                  _buildSubtitle(),
                  const SizedBox(height: 24),
                  _buildPasswordField(
                    'New Password',
                    _newPasswordController,
                    _obscureNewPassword,
                    () => setState(
                      () => _obscureNewPassword = !_obscureNewPassword,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _buildPasswordField(
                    'Confirm Password',
                    _confirmPasswordController,
                    _obscureConfirmPassword,
                    () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                    isConfirmPassword: true,
                  ),
                  const SizedBox(height: 20),
                  CustomElevatedButton(
                    text: 'Update Password',
                    onPressed: _handleUpdatePassword,
                  ),
                  const SizedBox(height: 16),
                  _buildBackToLoginButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/T.png', height: 50),
              const SizedBox(width: 2),
              Image.asset('assets/K.png', height: 50),
              const SizedBox(width: 2),
              Image.asset('assets/X.png', height: 50),
            ],
          ),
          const SizedBox(height: 6),
          Image.asset('assets/Ticketing.png', height: 30),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Set a New Password',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Text(
      'Create a strong password to protect your account.',
      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.4),
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool obscure,
    VoidCallback toggle, {
    bool isConfirmPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1F5CBF), width: 1.5),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: const Color(0xFF9CA3AF),
            size: 20,
          ),
          onPressed: toggle,
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        if (isConfirmPassword && value != _newPasswordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Widget _buildBackToLoginButton() {
    return Center(
      child: TextButton(
        onPressed: _handleBackToLogin,
        child: const Text(
          'Back to Login',
          style: TextStyle(
            color: Color(0xFF1F5CBF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
