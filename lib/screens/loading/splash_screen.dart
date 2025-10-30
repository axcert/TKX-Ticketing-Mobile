import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onFinished;

  const SplashScreen({
    Key? key,
    this.duration = const Duration(seconds: 2),
    this.onFinished,
  }) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fade;
  late final AnimationController _rotationController;
  late final Animation<double> _rotation;
  bool _showTicketing = false;
  bool _hideContent = false;

  @override
  void initState() {
    super.initState();

    // Fade-in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    // Rotation animation for X - one complete rotation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _rotation = CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut);

    _fadeController.forward();

    // Start X rotation - one complete rotation
    _rotationController.forward();

    // Show "Ticketing" text after 1 second
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showTicketing = true;
        });
      }
    });

    // Hide TKX and Ticketing content after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _hideContent = true;
        });
      }
    });

    // Simulate initialization or wait for [duration] then navigate/callback
    Timer(widget.duration, () {
      widget.onFinished?.call();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fade,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Background image from assets
            Image.asset(
              'assets/splash_bg.png',
              fit: BoxFit.fill,
              width: double.infinity,
              height: double.infinity,
            ),

            // Layer 2: White color overlay with low opacity to lighten the background
            Container(
              color: const Color(0xFFFFFFFF).withValues(alpha: 0.9), // 30% white overlay to lighten
            ),

            // Layer 3: Linear gradient overlay with some transparency
            // Colors from your Figma: Primary (#1F5CBF) to Logo color (#27AAE1)
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1F5CBF).withValues(alpha: 0.2), // Primary color with transparency
                    const Color(0xFF27AAE1).withValues(alpha: 0.2), // Logo color with transparency
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),

            // Layer 4: Content - TKX Logo with rotating X
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Responsive sizing based on screen height and width
                  final screenHeight = constraints.maxHeight;
                  final screenWidth = constraints.maxWidth;
                  final isSmallScreen = screenHeight < 600 || screenWidth < 360;
                  final logoHeight = isSmallScreen ? screenHeight * 0.08 : screenHeight * 0.1;
                  final ticketingHeight = isSmallScreen ? screenHeight * 0.05 : screenHeight * 0.065;
                  final spacing = isSmallScreen ? 2.0 : 3.0;
                  final topPadding = isSmallScreen ? 2.0 : 4.0;

                  return Center(
                    child: AnimatedOpacity(
                      opacity: _hideContent ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // TKX Logo with rotating X
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // T letter
                              SvgPicture.asset(
                                'assets/T.svg',
                                height: logoHeight,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: spacing),
                              // K letter
                              SvgPicture.asset(
                                'assets/K.svg',
                                height: logoHeight,
                                fit: BoxFit.contain,
                              ),
                              SizedBox(width: spacing),
                              // X letter with rotation animation
                              RotationTransition(
                                turns: _rotation,
                                child: SvgPicture.asset(
                                  'assets/X.svg',
                                  height: logoHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),

                          // Animated "Ticketing" text that appears after 1 second
                          AnimatedOpacity(
                            opacity: _showTicketing ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 500),
                            child: Padding(
                              padding: EdgeInsets.only(top: topPadding),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/Ticketing (1).svg',
                                  height: ticketingHeight,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}