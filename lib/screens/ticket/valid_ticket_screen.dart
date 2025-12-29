import 'package:flutter/material.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/services/ticket_service.dart';
import 'package:tkx_ticketing/widgets/custom_elevated_button.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing/providers/event_provider.dart';
import 'package:tkx_ticketing/providers/auth_provider.dart';
import 'package:tkx_ticketing/widgets/toast_message.dart';

class ValidTicketScreen extends StatefulWidget {
  final Map<String, dynamic> ticketData;
  final String eventId;
  final bool isCheckedIn;

  const ValidTicketScreen({
    super.key,
    required this.ticketData,
    required this.eventId,
    this.isCheckedIn = false,
  });

  @override
  State<ValidTicketScreen> createState() => _ValidTicketScreenState();
}

class _ValidTicketScreenState extends State<ValidTicketScreen> {
  final TicketService _ticketService = TicketService();
  bool _isProcessing = false;
  bool _isAutoCheckInEnabled = false;

  @override
  void initState() {
    super.initState();
    // If passed as checked in, we don't need to process
    if (widget.isCheckedIn) {
      _isProcessing = false;
    } else {
      // Check for auto check-in preference
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.user?.isAutoCheckIn == true) {
          setState(() {
            _isAutoCheckInEnabled = true;
          });
          // Auto check-in after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              _handleCheckIn();
            }
          });
        }
      });
    }
  }

  Future<void> _handleCheckIn() async {
    if (_isProcessing) return;

    // If already checked in mode, just close
    if (widget.isCheckedIn) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    final ticketId = widget.ticketData['ticketId'] as String?;
    if (ticketId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid ticket data'),
          backgroundColor: AppColors.error,
        ),
      );
      setState(() => _isProcessing = false);
      return;
    }

    // Call service to check in
    final result = await _ticketService.checkInTicket(widget.eventId, ticketId);

    if (!mounted) return;

    if (result['success'] == true) {
      if (mounted) {
        final provider = context.read<EventProvider>();
        await provider.addPendingCheckIn(ticketId, widget.eventId);

        // Add to scan history for immediate UI update
        await provider.addScanToHistory({
          'ticketId': ticketId,
          'name': widget.ticketData['name'] ?? 'Unknown',
          'status': 'valid',
          'scanTime': DateTime.now().toIso8601String(),
          'isVip': widget.ticketData['isVip'] ?? false,
          'recordId': widget.ticketData['recordId'],
          'seatNo': widget.ticketData['seatNo'],
          'scanType': 'QR Scan',
        }, widget.eventId);
      }

      ToastMessage.show(
        context,
        message: 'Check-in successful',
        type: ToastType.success,
      );
      // Brief delay for user feedback
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context, true);
      }
    } else {
      ToastMessage.show(
        context,
        message: 'Check-in failed: ${result['message']}',
        type: ToastType.error,
      );
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.textPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 24),
            height: MediaQuery.of(context).size.height * 0.85,
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/valid.png'),
                alignment: Alignment.center,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${widget.ticketData['recordId'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${widget.ticketData['checkedCount'] ?? '325'}/${widget.ticketData['totalCount'] ?? '500'}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                Container(
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: widget.ticketData['isVip']
                                ? AssetImage('assets/vip.png')
                                : AssetImage('assets/normal.png'),
                            alignment: Alignment.center,
                          ),
                        ),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                      Text(
                        widget.ticketData['name'] ?? 'N/A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  child: Column(
                    children: [
                      Text(
                        widget.isCheckedIn ? "Checked In" : "Valid Ticket",
                        style: Theme.of(context).textTheme.displayLarge!
                            .copyWith(
                              fontSize: 40,
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        widget.ticketData['ticketId'] ?? 'N/A',
                        style: Theme.of(context).textTheme.headlineMedium!
                            .copyWith(
                              color: AppColors.background,
                              fontWeight: FontWeight.normal,
                            ),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 100,
                  width: 150,
                  decoration: BoxDecoration(
                    color: AppColors.background.withOpacity(0.2),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.ticketData['seatNo'] ?? 'N/A',
                          style: Theme.of(context).textTheme.displayLarge!
                              .copyWith(color: AppColors.background),
                        ),
                        Text(
                          'Seat No',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(color: AppColors.background),
                        ),
                      ],
                    ),
                  ),
                ),

                if (_isAutoCheckInEnabled && !widget.isCheckedIn)
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.background,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Checking in automatically...",
                        style: TextStyle(
                          color: AppColors.background,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                else
                  CustomElevatedButton(
                    backgroundColor: _isProcessing
                        ? Colors.grey
                        : AppColors.background,
                    textColor: AppColors.textPrimary,
                    text: widget.isCheckedIn
                        ? "Next"
                        : (_isProcessing ? "Checking in..." : "Check-in"),
                    isLoading: _isProcessing,
                    onPressed: () => _handleCheckIn(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
