import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/models/ticket_model.dart';
import 'package:tkx_ticketing/screens/ticket/valid_ticket_screen.dart';
import 'package:tkx_ticketing/screens/ticket/already_checked_in_screen.dart';
import 'package:tkx_ticketing/services/ticket_service.dart';

class ManualCheckInBottomSheet extends StatefulWidget {
  final String eventId;

  const ManualCheckInBottomSheet({super.key, required this.eventId});

  @override
  State<ManualCheckInBottomSheet> createState() =>
      _ManualCheckInBottomSheetState();
}

class _ManualCheckInBottomSheetState extends State<ManualCheckInBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TicketService _ticketService = TicketService();

  List<Ticket> _allTickets = [];
  List<Ticket> _filteredTickets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final tickets = await _ticketService.loadTicketsLocally(widget.eventId);
    if (mounted) {
      setState(() {
        _allTickets = tickets;
        _isLoading = false;
      });
    }
  }

  void _filterTickets(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredTickets = [];
      });
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredTickets = _allTickets.where((ticket) {
        return ticket.attendeeName.toLowerCase().contains(lowerQuery) ||
            ticket.attendeePublicId.toLowerCase().contains(lowerQuery) ||
            ticket.attendeeEmail.toLowerCase().contains(lowerQuery);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textHint,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Manual Check-In',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Search Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by Name, ID or Email...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                  size: 22,
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: _filterTickets,
            ),
          ),

          const SizedBox(height: 24),

          // Search Results Area
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchController.text.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Search for attendees',
                          style: Theme.of(context).textTheme.titleMedium!
                              .copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter name, ID or email to check-in',
                          style: Theme.of(context).textTheme.titleSmall!
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  )
                : _filteredTickets.isEmpty
                ? Center(
                    child: Text(
                      'No attendees found',
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _filteredTickets.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final ticket = _filteredTickets[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border(
                            bottom: BorderSide(
                              width: 1,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor: AppColors.textSecondary
                                .withOpacity(0.1),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: SvgPicture.asset(
                                "assets/icons/tickets.svg",
                              ),
                            ),
                          ),
                          title: Text(
                            ticket.attendeeName,
                            style: Theme.of(context).textTheme.titleMedium!
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket.attendeeEmail,
                                style: Theme.of(context).textTheme.bodyMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              Text(
                                'ID: ${ticket.attendeePublicId}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppColors.textHint,
                          ),
                          onTap: () {
                            // Calculate counts
                            final totalCount = _allTickets.length;
                            final checkedCount = _allTickets
                                .where((t) => t.status == 'checked-in')
                                .length;

                            final ticketData = {
                              'recordId': ticket.ticketId.toString(),
                              'checkedCount': checkedCount.toString(),
                              'totalCount': totalCount.toString(),
                              'isVip': ticket.ticketType.toLowerCase() == 'vip',
                              'name': ticket.attendeeName,
                              'ticketId': ticket.attendeePublicId,
                              'seatNo': ticket.seatNumber ?? 'N/A',
                              'row': '-', // Placeholder
                              'column': '-', // Placeholder
                            };

                            if (ticket.isCheckedIn) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AlreadyCheckedInScreen(
                                    ticketData: ticketData,
                                  ),
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ValidTicketScreen(
                                    ticketData: ticketData,
                                    eventId: widget.eventId,
                                  ),
                                ),
                              ).then((result) {
                                if (result == true) {
                                  // Refresh the ticket list after a successful check-in
                                  _loadTickets();
                                  // Close bottom sheet if desired, or stay to check in more
                                  // Navigator.pop(context);
                                }
                              });
                            }
                          },
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

// Function to show the bottom sheet
void showManualCheckInBottomSheet(BuildContext context, String eventId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ManualCheckInBottomSheet(eventId: eventId),
  );
}
