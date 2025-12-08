import 'package:flutter/material.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/services/ticket_service.dart';
import 'package:tkx_ticketing/widgets/custom_elevated_button.dart';
import 'package:tkx_ticketing/widgets/toast_message.dart';

class OfflineCheckInScreen extends StatefulWidget {
  final String eventId;
  final String eventName;

  const OfflineCheckInScreen({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<OfflineCheckInScreen> createState() => _OfflineCheckInScreenState();
}

class _OfflineCheckInScreenState extends State<OfflineCheckInScreen> {
  final TicketService _ticketService = TicketService();
  bool _isDownloading = true;
  int _syncedTickets = 0;
  int _totalTickets = 0;
  double _progress = 0.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  void _startDownload() async {
    try {
      setState(() {
        _isDownloading = true;
        _errorMessage = null;
      });

      // Fetch tickets from API
      final ticketBundle = await _ticketService.fetchTicketsForEvent(
        widget.eventId,
      );

      if (ticketBundle == null) {
        throw Exception('Failed to fetch tickets from server');
      }

      if (!mounted) return;

      // Check if ticket list is empty
      if (ticketBundle.count == 0 || ticketBundle.tickets.isEmpty) {
        // Show toast message for empty tickets
        if (mounted) {
          ToastMessage.show(
            type: ToastType.warning,
            message: 'No tickets available for this event yet',
            context,
            duration: const Duration(seconds: 3),
          );

          // Navigate back with true to proceed to EventDetailsScreen
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.pop(context, true);
          }
        }
        return;
      }

      // Update total tickets count
      setState(() {
        _totalTickets = ticketBundle.count;
      });

      // Simulate progress for better UX (since API call is instant)
      // In real scenario, you might download in batches
      for (int i = 0; i <= _totalTickets; i += (_totalTickets / 10).ceil()) {
        await Future.delayed(const Duration(milliseconds: 150));
        if (mounted) {
          setState(() {
            _syncedTickets = i > _totalTickets ? _totalTickets : i;
            _progress = _syncedTickets / _totalTickets;
          });
        }
      }

      // Save tickets locally
      final saved = await _ticketService.saveTicketsLocally(
        widget.eventId,
        ticketBundle.tickets,
      );

      if (!saved) {
        throw Exception('Failed to save tickets locally');
      }

      // Download complete
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _syncedTickets = _totalTickets;
          _progress = 1.0;
        });

        // Wait a moment then navigate back
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          Navigator.pop(
            context,
            true,
          ); // Return true to indicate download completed
        }
      }
    } catch (e) {
      // Handle errors
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ticket Icon
                  Center(
                    child: Image.asset(
                      'assets/online-ticket 2.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icon if image fails to load
                        return const Icon(
                          Icons.confirmation_number_outlined,
                          size: 48,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Preparing Offline Check-In',
                    style: Theme.of(context).textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    _errorMessage ??
                        'Connecting to the server and retrieving the latest ticket information.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _errorMessage != null
                          ? AppColors.error
                          : AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Progress Bar or Error State
                  if (_errorMessage == null)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: _totalTickets > 0 ? _progress : null,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF6366F1),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _totalTickets > 0
                              ? 'Syncing ticket $_syncedTickets of $_totalTickets'
                              : 'Fetching ticket information...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  if (_errorMessage != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _startDownload,
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  else if (_isDownloading)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
