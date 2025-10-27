import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
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

          // Layer 4: Content - Forgot Password Form
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
                            // Forgot Password Card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 32),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
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

                                    // Forgot Password text
                                    const Text(
                                      'Forgot Password',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Enter the email you used to register',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF6B7280),
                                        height: 1.4,
                                      ),
                                    ),

                                    const SizedBox(height: 24),

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
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color(0xFFE5E7EB),
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
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
                                        if (!RegExp(
                                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                            .hasMatch(value)) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 24),

                                    // Send Reset Code Button
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            // Handle send reset code
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Reset code sent to your email'),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF5B8DEE),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: const Text(
                                          'Send Reset Code',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // Back to Login link
                                    Center(
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 0,
                                            vertical: 8,
                                          ),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
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
