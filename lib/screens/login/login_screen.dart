import 'dart:async';
import 'package:flutter/material.dart';
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

  void _backToForgotPassword() {
    setState(() {
      _animationController.reset();
      _isVerification = false;
      _animationController.forward();
    });
    _timer?.cancel();
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

          // Layer 2: Light blue color overlay with high opacity
          Container(
            color: const Color(0xFFE8F4F8).withValues(alpha: 0.95),
          ),

          // Layer 3: Login background image overlay with reduced opacity
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: 0.1,
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
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Container(),
                            ),
                            // Welcome Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 20,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
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
                                  Image.asset(
                                    'assets/T.png',
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 2),
                                  // K letter
                                  Image.asset(
                                    'assets/K.png',
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                  const SizedBox(width: 2),
                                  // X letter
                                  Image.asset(
                                    'assets/X.png',
                                    height: 50,
                                    fit: BoxFit.contain,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Ticketing text
                            Center(
                              child: Image.asset(
                                'assets/Ticketing.png',
                                height: 30,
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Welcome text or Forgot Password or Verification or Set New Password text with animation
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                _isSetNewPassword
                                    ? 'Set a New Password'
                                    : (_isVerification
                                        ? 'Verify Your Identity'
                                        : (_isForgotPassword ? 'Forgot Password' : 'Welcome!')),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                _isSetNewPassword
                                    ? 'Create a strong password to protect your account.'
                                    : (_isVerification
                                        ? 'Enter the verification code we send to\n${_emailController.text.isNotEmpty ? _emailController.text : 'i****@gamil.com'}'
                                        : (_isForgotPassword
                                            ? 'Enter the email you used to register'
                                            : 'Sign in to manage tickets and ticket\nhappening.')),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                  height: 1.4,
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

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

                              const SizedBox(height: 18),

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
                              const SizedBox(height: 20),
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
                                      const SizedBox(height: 18),

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

                              const SizedBox(height: 8),

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

                            const SizedBox(height: 20),

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

                            // Show "Back to Login" link when not in normal login mode
                            if (_isForgotPassword || _isVerification || _isSetNewPassword) ...[
                              const SizedBox(height: 16),
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
                                    } else if (_isVerification) {
                                      _backToForgotPassword();
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

                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
