import 'package:flutter/material.dart';

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
  bool _isDownloading = true;
  int _syncedTickets = 0;
  final int _totalTickets = 500;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startDownload();
  }

  void _startDownload() async {
    // Simulate downloading ticket data
    for (int i = 0; i <= _totalTickets; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _syncedTickets = i;
          _progress = i / _totalTickets;
        });
      }
    }

    // Download complete
    if (mounted) {
      setState(() {
        _isDownloading = false;
        _syncedTickets = _totalTickets;
        _progress = 1.0;
      });

      // Wait a moment then show completion message or navigate back
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate download completed
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
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
                border: Border.all(
                  color: const Color(0xFF6366F1),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ticket Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/online-ticket 2.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback to icon if image fails to load
                          return const Icon(
                            Icons.confirmation_number_outlined,
                            size: 48,
                            color: Color(0xFF6366F1),
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Preparing Offline Check-In',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    'Connecting to the server and retrieving the\nlatest ticket information.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  // Progress Bar
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Syncing ticket $_syncedTickets of $_totalTickets',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Cancel Button (optional)
                  if (_isDownloading)
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
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
