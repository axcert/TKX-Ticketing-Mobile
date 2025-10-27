import 'package:flutter/material.dart';

class ValidTicketScreen extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const ValidTicketScreen({
    super.key,
    required this.ticketData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with count
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${ticketData['recordId'] ?? '0012'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${ticketData['checkedCount'] ?? '325'}/${ticketData['totalCount'] ?? '500'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Green ticket card
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                child: ClipPath(
                  clipper: TicketClipper(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF098E17),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF098E17).withValues(alpha: 0.5),
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
                        opacity: 0.3,
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
                        opacity: 0.3,
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
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 120),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),

                          // Profile Icon with VIP Badge
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Profile Icon with yellow border
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: const Color(0xFFFFD700),
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFF098E17),
                                ),
                              ),
                              // VIP Badge positioned at top
                              if (ticketData['isVip'] == true)
                                Positioned(
                                  top: -10,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFD700),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Text(
                                        'VIP',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Name
                          Text(
                            ticketData['name'] ?? 'N/A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 30),

                          // Valid Ticket
                          const Text(
                            'Valid Ticket',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Ticket ID (display only ticket id; if a URL is provided show last path segment)
                          Text(
                            (() {
                              final t = ticketData['ticketId'] ?? 'TCK-98432';
                              try {
                                final uri = Uri.parse(t);
                                if (uri.hasScheme && uri.pathSegments.isNotEmpty) {
                                  return uri.pathSegments.last;
                                }
                              } catch (_) {}
                              return t;
                            })(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 40),

                          // Seat Number tile (translucent)
                          Container(
                            width: 290,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  ticketData['seatNo'] ?? 'A31',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Seat No.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Row : ${ticketData['row'] ?? 'A'}   Column : ${ticketData['column'] ?? '31'}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    // Positioned Check-In Button inside green tile
                    Positioned(
                      bottom: 64,
                      left: 24,
                      right: 24,
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            // Perform check-in action
                            Navigator.pop(context, true); // Return true to indicate check-in completed
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF098E17),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Check-In',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Positioned Cancel (inside green tile, smaller link)
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
