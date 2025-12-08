import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/widgets/event_card.dart';
import '../../models/event_model.dart';

class ScanNotAvailableScreen extends StatelessWidget {
  final Event event;

  const ScanNotAvailableScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Event Info Card
          Container(height: 60, color: AppColors.primary),
          Transform.translate(
            offset: const Offset(0, -40),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: EventCard(event: event),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          // White Content Area
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Ticket Icon
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: SvgPicture.asset('assets/ticket_not_available.svg'),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  Text(
                    'Scan Not Yet Available',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    'Ticket scanning will open 4 hours before the event starts.\nPlease return closer to the event time.',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
