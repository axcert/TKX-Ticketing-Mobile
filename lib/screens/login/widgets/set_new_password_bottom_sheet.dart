import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'login_bottom_sheet.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/toast_message.dart';
import '../../../providers/auth_provider.dart';

class SetNewPasswordBottomSheet extends StatefulWidget {
  final String email;
  final String otp;

  const SetNewPasswordBottomSheet({
    super.key,
    required this.email,
    required this.otp,
  });

  static void show(
    BuildContext context, {
    required String email,
    required String otp,
  }) {
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
            child: SetNewPasswordBottomSheet(email: email, otp: otp),
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

  Future<void> _handleUpdatePassword() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.resetPassword(
        widget.email,
        widget.otp,
        _newPasswordController.text,
        _confirmPasswordController.text,
      );

      if (success && mounted) {
        // Password reset successful
        ToastMessage.success(context, 'Password updated successfully!');

        // Navigate back to login
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
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
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
      } else if (mounted && authProvider.errorMessage != null) {
        // Show error message
        ToastMessage.error(context, authProvider.errorMessage!);
      }
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
                  SizedBox(
                    width: 300,
                    height: 100,
                    child: SvgPicture.asset('assets/tkx_logo.svg'),
                  ),
                  const SizedBox(height: 50),
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
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return CustomElevatedButton(
                        text: 'Update Password',
                        onPressed: _handleUpdatePassword,
                        isLoading: authProvider.isLoading,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Set a New Password',
      style: Theme.of(context).textTheme.headlineLarge!.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: 25,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Create a strong password to protect your account.',
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
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
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: AppColors.textSecondary,
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
}
