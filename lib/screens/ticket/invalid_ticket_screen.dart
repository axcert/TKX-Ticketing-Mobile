import 'package:flutter/material.dart';

class InvalidTicketScreen extends StatelessWidget {
  final Map<String, dynamic>? ticketData;

  const InvalidTicketScreen({
    super.key,
    this.ticketData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with record ID
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${ticketData?['recordId'] ?? '0012'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Red ticket card
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipPath(
                  clipper: TicketClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFD32F2F),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD32F2F).withValues(alpha: 0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background round images
                        Positioned(
                          top: -40,
                          right: -40,
                          child: Opacity(
                            opacity: 0.2,
                            child: Image.asset(
                              'assets/round1.png',
                              width: 150,
                              height: 150,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -50,
                          left: -50,
                          child: Opacity(
                            opacity: 0.2,
                            child: Image.asset(
                              'assets/round2.png',
                              width: 180,
                              height: 180,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const SizedBox(),
                            ),
                          ),
                        ),
                        // Main content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // X Icon in circle
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 40),

                              // Invalid Ticket
                              const Text(
                                'Invalid Ticket',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 8),

                              // Ticket ID if available
                              if (ticketData?['ticketId'] != null)
                                Text(
                                  ticketData!['ticketId'],
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Positioned Scan Again Button inside red tile
                        Positioned(
                          bottom: 64,
                          left: 24,
                          right: 24,
                          child: SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFFD32F2F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Scan Again',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Positioned Cancel (inside red tile, smaller link)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 0),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Custom clipper for ticket shape with side notches
class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const radius = 24.0;
    const notchRadius = 15.0;
    const notchPosition = 0.68; // Position from top (68%)

    // Start from top-left
    path.moveTo(radius, 0);

    // Top edge
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);

    // Right edge to notch
    final rightNotchY = size.height * notchPosition;
    path.lineTo(size.width, rightNotchY - notchRadius);

    // Right notch (curve inward)
    path.arcToPoint(
      Offset(size.width, rightNotchY + notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    // Right edge after notch
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);

    // Bottom edge
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);

    // Left edge after notch
    path.lineTo(0, rightNotchY + notchRadius);

    // Left notch (curve inward)
    path.arcToPoint(
      Offset(0, rightNotchY - notchRadius),
      radius: const Radius.circular(notchRadius),
      clockwise: false,
    );

    // Left edge to top
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
