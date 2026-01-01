import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'otp_verification_bottom_sheet.dart';
import 'login_bottom_sheet.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/toast_message.dart';
import '../../../providers/auth_provider.dart';

class ForgotPasswordBottomSheet extends StatefulWidget {
  const ForgotPasswordBottomSheet({super.key});

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
            child: const ForgotPasswordBottomSheet(),
          ),
        );
      },
    );
  }

  @override
  State<ForgotPasswordBottomSheet> createState() =>
      _ForgotPasswordBottomSheetState();
}

class _ForgotPasswordBottomSheetState extends State<ForgotPasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final success = await authProvider.forgotPassword(
        _emailController.text.trim(),
      );

      if (success && mounted) {
        // Code sent successfully, navigate to OTP screen
        // Show message from backend
        final message =
            authProvider.successMessage ??
            'Verification code sent to your email';
        ToastMessage.success(context, message);
        Navigator.pop(context);
        OtpVerificationBottomSheet.show(
          context,
          email: _emailController.text.trim(),
        );
      } else if (mounted && authProvider.errorMessage != null) {
        // Show error message from backend
        ToastMessage.error(context, authProvider.errorMessage!);
      }
    }
  }

  void _handleBackToLogin() {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (context.mounted) {
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        _handleBackToLogin();
      },
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
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
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 300,
                        height: 100,
                        child: SvgPicture.asset('assets/tkx_logo.svg'),
                      ),
                    ),
                    const SizedBox(height: 50),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildSubtitle(),
                    const SizedBox(height: 24),
                    _buildEmailField(),
                    const SizedBox(height: 20),
                    Consumer<AuthProvider>(
                      builder: (context, authProvider, child) {
                        return CustomElevatedButton(
                          text: 'Send Reset Code',
                          onPressed: _handleSendCode,
                          isLoading: authProvider.isLoading,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildBackToLoginButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'Forgot Password',
      style: Theme.of(context).textTheme.headlineLarge!.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: 25,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Enter the email you used to register',
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(labelText: 'Email'),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildBackToLoginButton() {
    return Center(
      child: TextButton(
        onPressed: _handleBackToLogin,
        child: Text(
          'Back to Login',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontFamily: GoogleFonts.inter().fontFamily,
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
