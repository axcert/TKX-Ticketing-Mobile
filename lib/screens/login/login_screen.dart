import 'package:flutter/material.dart';
import 'widgets/login_background.dart';
import 'widgets/login_bottom_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();

  /// Shows the login screen as a bottom sheet with background
  static void showAsBottomSheet(BuildContext context) {
    // First show the background screen without animation
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginBackgroundScreen(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: const Duration(milliseconds: 300),
      ),
    );

    // Show bottom sheet with slide-up animation
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
                position: Tween<Offset>(
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

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
