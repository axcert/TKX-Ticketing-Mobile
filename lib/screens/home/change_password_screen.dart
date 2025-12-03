import 'package:flutter/material.dart';
import 'package:mobile_app/config/app_theme.dart';
import 'package:mobile_app/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/auth_provider.dart';
import '../../widgets/toast_message.dart';
import 'set_new_password_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  int _secondsRemaining = 30;
  Timer? _timer;
  bool _isInitializing = true;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _initializePasswordChange();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializePasswordChange() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Get user email from the provider
    _userEmail = authProvider.user?.email;

    if (_userEmail == null || _userEmail!.isEmpty) {
      if (mounted) {
        ToastMessage.error(
          context,
          'User email not found. Please login again.',
        );
        Navigator.pop(context);
      }
      return;
    }

    // Send OTP to user's email
    final success = await authProvider.forgotPassword(_userEmail!);

    setState(() {
      _isInitializing = false;
    });

    if (mounted) {
      if (success) {
        ToastMessage.success(
          context,
          authProvider.successMessage ?? 'Verification code sent to your email',
        );
        _startTimer();
      } else {
        ToastMessage.error(
          context,
          authProvider.errorMessage ?? 'Failed to send verification code',
        );
        Navigator.pop(context);
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = 30;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendCode() async {
    if (_userEmail == null) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.forgotPassword(_userEmail!);

    if (mounted) {
      if (success) {
        _startTimer();
        ToastMessage.success(
          context,
          authProvider.successMessage ?? 'Verification code resent',
        );
      } else {
        ToastMessage.error(
          context,
          authProvider.errorMessage ?? 'Failed to resend code',
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    String otp = _otpControllers.map((controller) => controller.text).join();

    if (otp.length != 6) {
      ToastMessage.error(context, 'Please enter complete verification code');
      return;
    }

    if (_userEmail == null) {
      ToastMessage.error(context, 'User email not found');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.verifyOtp(_userEmail!, otp);

    if (mounted) {
      if (success) {
        ToastMessage.success(context, 'Code verified successfully');
        // Navigate to Set New Password screen with email and OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SetNewPasswordScreen(email: _userEmail!, otp: otp),
          ),
        );
      } else {
        ToastMessage.error(
          context,
          authProvider.errorMessage ?? 'Invalid verification code',
        );
      }
    }
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return '';

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    return '${username[0]}${'*' * (username.length - 1)}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const SizedBox(height: 80),

                      // Title
                      Text(
                        'Verify Your Identity',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      // Subtitle
                      Text(
                        'Enter the verification code we sent to',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userEmail != null ? _maskEmail(_userEmail!) : '',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 40),

                      // OTP Input Fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 45,
                            height: 55,
                            child: TextField(
                              controller: _otpControllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium!,
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty && index < 5) {
                                  // Move to next field
                                  _focusNodes[index + 1].requestFocus();
                                } else if (value.isEmpty && index > 0) {
                                  // Move to previous field
                                  _focusNodes[index - 1].requestFocus();
                                }
                              },
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 24),

                      // Resend Code Text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't get the code? ",
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                          if (_secondsRemaining > 0)
                            Text(
                              'Resend in ${_secondsRemaining}s',
                              style: Theme.of(context).textTheme.titleSmall!
                                  .copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w400,
                                  ),
                            )
                          else
                            GestureDetector(
                              onTap: authProvider.isLoading
                                  ? null
                                  : _resendCode,
                              child: Text(
                                'Resend',
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(
                                      color: authProvider.isLoading
                                          ? AppColors.textSecondary
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                        ],
                      ),

                      const Spacer(),

                      // Verify Code Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: CustomElevatedButton(
                          text: "Verify Code",
                          onPressed: _verifyCode,
                          isLoading: authProvider.isLoading,
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
