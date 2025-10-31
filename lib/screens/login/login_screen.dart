import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isForgotPassword = false;
  bool _isVerification = false;
  bool _isSetNewPassword = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // OTP Controllers
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  // New Password Controllers
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Timer
  int _countdown = 30;
  bool _canResend = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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

  void _toggleMode() {
    setState(() {
      _animationController.reset();
      _isForgotPassword = !_isForgotPassword;
      _animationController.forward();
    });
  }

  void _showVerification() {
    setState(() {
      _animationController.reset();
      _isVerification = true;
      _animationController.forward();
    });
    _startCountdown();
  }

  void _showSetNewPassword() {
    setState(() {
      _animationController.reset();
      _isVerification = false;
      _isSetNewPassword = true;
      _animationController.forward();
    });
    _timer?.cancel();
  }

  String _maskEmail(String email) {
    if (email.isEmpty) return 'test@gmail.com';

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    return '${username.substring(0, 2)}***@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: Background image (same as splash screen)
          Image.asset(
            'assets/splash_bg.png',
            fit: BoxFit.fill,
            width: double.infinity,
            height: double.infinity,
          ),

          // Layer 2: Light blue color overlay
          Container(
            color: const Color(0xFFC1E7F7).withValues(alpha: 0.70),
          ),

          // Layer 3: Login background image overlay with reduced opacity
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/login_bg.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Layer 4: Content - Logo and Login Form
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Detect small screens (like Samsung Galaxy S4 Mini)
                final isSmallScreen = constraints.maxHeight < 600 || constraints.maxWidth < 360;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Spacer to show background at top - more space in forgot password mode
                    // Balance between iPhone SE and Samsung screens
                    SizedBox(
                      height: constraints.maxHeight * (_isForgotPassword || _isVerification || _isSetNewPassword
                          ? (isSmallScreen ? 0.35 : 0.30)
                          : (isSmallScreen ? 0.30 : 0.20)),
                    ),
                    // Welcome Card - Expanded to fill remaining space
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.06,
                          vertical: constraints.maxHeight * (isSmallScreen ? 0.018 : 0.025),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                            // TKX Logo - Centered inside card
                            Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // T letter
                                  SvgPicture.asset(
                                    'assets/T.svg',
                                    height: constraints.maxHeight * (isSmallScreen ? 0.065 : 0.08),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.005),
                                  // K letter
                                  SvgPicture.asset(
                                    'assets/K.svg',
                                    height: constraints.maxHeight * (isSmallScreen ? 0.065 : 0.08),
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(width: constraints.maxWidth * 0.005),
                                  // X letter
                                  SvgPicture.asset(
                                    'assets/X.svg',
                                    height: constraints.maxHeight * (isSmallScreen ? 0.065 : 0.08),
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: constraints.maxHeight * (isSmallScreen ? 0.006 : 0.008)),

                            // Ticketing text
                            Center(
                              child: SvgPicture.asset(
                                'assets/Ticketing (1).svg',
                                height: constraints.maxHeight * (isSmallScreen ? 0.042 : 0.05),
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(height: constraints.maxHeight * (isSmallScreen ? 0.035 : 0.045)),

                            // Welcome text or Forgot Password or Verification or Set New Password text with animation
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                _isSetNewPassword
                                    ? 'Set a New Password'
                                    : (_isVerification
                                        ? 'Verify Your Identity'
                                        : (_isForgotPassword ? 'Forgot Password' : 'Welcome!')),
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.065,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.003),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                _isSetNewPassword
                                    ? 'Create a strong password to protect your account.'
                                    : (_isVerification
                                        ? 'Enter the verification code we send to\n${_maskEmail(_emailController.text)}'
                                        : (_isForgotPassword
                                            ? 'Enter the email you used to register'
                                            : 'Log in to manage event check-ins and ticket\nscanning.')),
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.033,
                                  color: const Color(0xFF6B7280),
                                  height: 1.3,
                                ),
                              ),
                            ),

                            SizedBox(height: constraints.maxHeight * 0.035),

                            // Show different fields based on mode
                            if (_isSetNewPassword) ...[
                              // New Password Field
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: TextFormField(
                                  controller: _newPasswordController,
                                  obscureText: _obscureNewPassword,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: 'New Password',
                                    labelStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1F5CBF),
                                        width: 1.5,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureNewPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF9CA3AF),
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
                                      return 'Please enter a password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              SizedBox(height: constraints.maxHeight * 0.022),

                              // Confirm Password Field
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  style: const TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    labelText: 'Confirm Password',
                                    labelStyle: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF9CA3AF),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF9FAFB),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFFE5E7EB),
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF1F5CBF),
                                        width: 1.5,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: const Color(0xFF9CA3AF),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
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
                              ),
                            ] else if (_isVerification) ...[
                              // OTP Input Fields
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Row(
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
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        decoration: InputDecoration(
                                          counterText: '',
                                          filled: true,
                                          fillColor: const Color(0xFFF9FAFB),
                                          contentPadding: EdgeInsets.zero,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE5E7EB),
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFE5E7EB),
                                              width: 1,
                                            ),
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
                                ),
                              ),
                            ] else ...[
                              // Email TextField
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9CA3AF),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF9FAFB),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF1F5CBF),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              ),
                            ],

                            // Show countdown timer and resend when in verification mode
                            if (_isVerification) ...[
                              SizedBox(height: constraints.maxHeight * 0.025),
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Don't get the code?  ",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                    if (_canResend)
                                      GestureDetector(
                                        onTap: () {
                                          _startCountdown();
                                          // Resend code logic here
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Verification code resent'),
                                            ),
                                          );
                                        },
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
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],

                            // Show password field only when in normal login mode
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: !_isForgotPassword && !_isVerification && !_isSetNewPassword
                                ? Column(
                                    children: [
                                      SizedBox(height: constraints.maxHeight * 0.022),

                                      // Password TextField
                                      FadeTransition(
                                        opacity: _fadeAnimation,
                                        child: TextFormField(
                                          controller: _passwordController,
                                          obscureText: _obscurePassword,
                                          style: const TextStyle(fontSize: 14),
                                          decoration: InputDecoration(
                                            labelText: 'Password',
                                            labelStyle: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF9CA3AF),
                                            ),
                                            filled: true,
                                            fillColor: const Color(0xFFF9FAFB),
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 14,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFFE5E7EB),
                                                width: 1,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF1F5CBF),
                                                width: 1.5,
                                              ),
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword
                                                    ? Icons.visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: const Color(0xFF9CA3AF),
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
                                                });
                                              },
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Please enter your password';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),

                              SizedBox(height: constraints.maxHeight * 0.02),

                              // Forgot Password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _toggleMode,
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: Color(0xFF1F5CBF),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                      ),

                            // Spacing before login button
                            SizedBox(height: constraints.maxHeight * 0.025),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            // Login Button or Send Reset Code or Verify Code or Update Password Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_isSetNewPassword) {
                                    // Handle update password
                                    if (_formKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Password updated successfully!'),
                                        ),
                                      );
                                      // Navigate back to login
                                      setState(() {
                                        _animationController.reset();
                                        _isSetNewPassword = false;
                                        _isForgotPassword = false;
                                        _animationController.forward();
                                      });
                                    }
                                  } else if (_isVerification) {
                                    // Handle verify code - navigate to set new password
                                    String otp = _otpControllers.map((c) => c.text).join();
                                    if (otp.length == 6) {
                                      _showSetNewPassword();
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please enter all 6 digits'),
                                        ),
                                      );
                                    }
                                  } else if (_formKey.currentState!.validate()) {
                                    if (_isForgotPassword) {
                                      // Handle send reset code - show verification
                                      _showVerification();
                                    } else {
                                      // Handle login - Navigate to Dashboard
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const HomeScreen(),
                                        ),
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5B8DEE),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  elevation: 0,
                                ),
                                child: FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Text(
                                    _isSetNewPassword
                                        ? 'Update Password'
                                        : (_isVerification
                                            ? 'Verify Code'
                                            : (_isForgotPassword ? 'Send Reset Code' : 'Login')),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Spacing after login button
                            SizedBox(height: constraints.maxHeight * 0.03),

                            // Show "Back to Login" link only on forgot password screen
                            if (_isForgotPassword && !_isVerification && !_isSetNewPassword) ...[
                              SizedBox(height: constraints.maxHeight * 0.02),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    if (_isSetNewPassword) {
                                      // Go back to login from set new password
                                      setState(() {
                                        _animationController.reset();
                                        _isSetNewPassword = false;
                                        _isForgotPassword = false;
                                        _animationController.forward();
                                      });
                                    } else {
                                      _toggleMode();
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 0,
                                      vertical: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: Color(0xFF1F5CBF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
