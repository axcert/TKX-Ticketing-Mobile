import 'dart:async';
import 'package:flutter/material.dart';
import 'set_new_password_bottom_sheet.dart';
import 'forgot_password_bottom_sheet.dart';
import '../../../widgets/custom_elevated_button.dart';

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

  void _handleVerifyCode() {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      Navigator.pop(context);
      SetNewPasswordBottomSheet.show(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 6 digits')),
      );
    }
  }

  void _handleResendCode() {
    _startCountdown();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification code resent')));
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
                _buildOtpFields(),
                const SizedBox(height: 20),
                _buildResendTimer(),
                const SizedBox(height: 20),
                CustomElevatedButton(
                  text: 'Verify Code',
                  onPressed: _handleVerifyCode,
                ),
                const SizedBox(height: 16),
                _buildBackButton(),
              ],
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
      'Verify Your Identity',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Text(
      'Enter the verification code we send to\n${widget.email}',
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF6B7280),
        height: 1.4,
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
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              counterText: '',
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: EdgeInsets.zero,
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
                borderSide: const BorderSide(
                  color: Color(0xFF1F5CBF),
                  width: 2,
                ),
              ),
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
        const Text(
          "Don't get the code?  ",
          style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
        if (_canResend)
          GestureDetector(
            onTap: _handleResendCode,
            child: const Text(
              'Resend',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF1F5CBF),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            'Resend in ${_countdown}s',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
      ],
    );
  }

  Widget _buildBackButton() {
    return Center(
      child: TextButton(
        onPressed: _handleBackToForgotPassword,
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
