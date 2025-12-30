import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'set_new_password_bottom_sheet.dart';
import 'forgot_password_bottom_sheet.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/toast_message.dart';
import '../../../providers/auth_provider.dart';

class OtpVerificationBottomSheet extends StatefulWidget {
  final String email;

  const OtpVerificationBottomSheet({super.key, required this.email});

  static void show(BuildContext context, {required String email}) {
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
            child: OtpVerificationBottomSheet(email: email),
          ),
        );
      },
    );
  }

  @override
  State<OtpVerificationBottomSheet> createState() =>
      _OtpVerificationBottomSheetState();
}

class _OtpVerificationBottomSheetState
    extends State<OtpVerificationBottomSheet> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 30;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _otpFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdown = 30;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _handleVerifyCode() async {
    String otp = _otpControllers.map((c) => c.text).join();

    if (otp.length != 6) {
      ToastMessage.warning(context, 'Please enter all 6 digits');
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.verifyOtp(widget.email, otp);

    if (success && mounted) {
      // OTP verified, navigate to set new password
      ToastMessage.success(context, 'Code verified successfully');
      Navigator.pop(context);
      SetNewPasswordBottomSheet.show(context, email: widget.email, otp: otp);
    } else if (mounted && authProvider.errorMessage != null) {
      // Show error message
      ToastMessage.error(context, authProvider.errorMessage!);
    }
  }

  void _handleResendCode() {
    _startCountdown();
    ToastMessage.info(context, 'Verification code resent');
  }

  void _handleBackToForgotPassword() {
    Navigator.pop(context);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        ForgotPasswordBottomSheet.show(context);
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
                _buildOtpFields(),
                const SizedBox(height: 20),
                _buildResendTimer(),
                const SizedBox(height: 20),
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
                    return CustomElevatedButton(
                      text: 'Verify Code',
                      onPressed: _handleVerifyCode,
                      isLoading: authProvider.isLoading,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String maskEmail(String email) {
    final parts = email.split('@');

    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return '${name[0]}*@${domain}';
    }

    final masked = name[0] + '*' * (name.length - 1);

    return '$masked@$domain';
  }

  Widget _buildTitle() {
    return Text(
      'Verify Your Identity',
      style: Theme.of(context).textTheme.headlineLarge!.copyWith(
        fontWeight: FontWeight.w900,
        fontSize: 25,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Enter the verification code we send to\n${maskEmail(widget.email)}',
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 45,
          height: 50,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _otpFocusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.surfaceDark,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < 5) {
                _otpFocusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _otpFocusNodes[index - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildResendTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't get the code?  ",
          style: Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 13),
        ),
        if (_canResend)
          GestureDetector(
            onTap: _handleResendCode,
            child: Text(
              'Resend',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Text(
            'Resend in ${_countdown}s',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(fontSize: 13),
          ),
      ],
    );
  }
}
