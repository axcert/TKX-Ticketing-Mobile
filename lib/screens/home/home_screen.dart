import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile_app/config/app_theme.dart';
import 'package:mobile_app/models/event_model.dart';
import 'package:mobile_app/widgets/offline_indicator.dart';
import 'side_menu.dart';
import 'tabs/upcoming_events_tab.dart';
import 'tabs/completed_events_tab.dart';
import '../event/event_details_screen.dart';
import '../event/scan_not_available_screen.dart';
import '../event/offline_checkin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODAY'S EVENTS - Events happening today (for featured card at top)
  // Replace with actual data from Today's Events API
  final List<Event> _todayEvents = [
    // Event(
    //   id: 'today-1',
    //   title: 'THE SHOGUN SHIFT...',
    //   imageUrl: 'assets/event_placeholder.png',
    //   dateTime: DateTime(2025, 10, 12, 18, 0),
    //   venue: 'Kulasingha Auditorium',
    //   location: 'Ananda College',
    // ),
    // Event(
    //   id: 'today-1',
    //   title: 'THE SHOGUN bs...',
    //   imageUrl: 'assets/event_placeholder.png',
    //   dateTime: DateTime(2025, 10, 12, 18, 0),
    //   venue: 'Kulasingha Auditorium',
    //   location: 'Ananda College',
    // ),
  ];

  // UPCOMING EVENTS - Future events (for bottom list)
  // Replace with actual data from Upcoming Events API
  // Setting events to 7 days in the future to test "upcoming" behavior
  final List<Event> _upcomingEvents = [
    // Event(
    //   id: 'upcoming-3',
    //   title: 'Marambari',
    //   imageUrl: 'assets/event_placeholder.png',
    //   dateTime: DateTime.now().add(const Duration(days: 9)),
    //   venue: 'Kulasingha Auditorium',
    //   location: 'Ananda College',
    // ),
  ];

  // COMPLETED EVENTS
  final List<Event> _completedEvents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _getTodayDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMM d, yyyy').format(now);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(child: SideMenu()),

      body: Column(
        children: [
          // Offline Indicator

          // App Bar
          SizedBox(height: MediaQuery.of(context).padding.top),
          const OfflineIndicator(),
          _buildAppBar(context),

          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
              // scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  // Blue background with cards on top
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Blue Background
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          children: [
                            Text(
                              "Today's Events",
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    color: AppColors.textWhite,
                                    fontSize: 26,
                                    fontFamily: GoogleFonts.plusJakartaSans()
                                        .fontFamily,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getTodayDate(),
                              style: Theme.of(context).textTheme.displayMedium!
                                  .copyWith(
                                    color: AppColors.border,
                                    fontSize: 18,
                                    fontFamily: GoogleFonts.plusJakartaSans()
                                        .fontFamily,
                                  ),
                            ),
                          ],
                        ),
                      ),

                      // Today's Event Cards positioned on top
                      if (_todayEvents.isNotEmpty)
                        Positioned(
                          top: 140,
                          left: 16,
                          right: 16,
                          child: Column(
                            children: _todayEvents
                                .map(
                                  (event) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _buildTodayEventCard(event),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      // No Events message overlapping blue and white sections
                      if (_todayEvents.isEmpty)
                        Positioned(
                          top: 160,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 150,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/no_today_event.svg',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Space for cards that extend beyond blue background
                  SizedBox(
                    height: _todayEvents.isEmpty
                        ? 120
                        : (_todayEvents.length * 100).toDouble(),
                  ),

                  // Events Section Header with Tabs
                  Container(
                    color: AppColors.textWhite,
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Events',
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),

                        TabBar(
                          controller: _tabController,
                          labelColor: AppColors.primary,
                          unselectedLabelColor: AppColors.surfaceDark,
                          labelStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),

                          unselectedLabelStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: AppColors.surfaceDark,
                          ),
                          indicatorWeight: 2,
                          tabs: const [
                            Tab(text: 'Upcoming events'),
                            Tab(text: 'Completed events'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Events List based on selected tab
                  Container(
                    color: AppColors.surface,
                    child: _tabController.index == 0
                        ? UpcomingEventsTab(events: _upcomingEvents)
                        : CompletedEventsTab(events: _completedEvents),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: AppColors.primary),
      child: Stack(
        children: [
          // Menu Icon on the left
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: AppColors.textWhite,
                    size: 24,
                  ),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),

          // Organization Name - Centered
          Center(
            child: Text(
              'Lotus Event',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(color: AppColors.textWhite),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.shadow.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          // Navigate to different screens based on event status
          if (event.isUpcoming) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScanNotAvailableScreen(event: event),
              ),
            );
          } else {
            // Show offline check-in preparation screen first
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OfflineCheckInScreen(
                  eventId: event.id,
                  eventName: event.title,
                ),
              ),
            );

            // If download completed successfully, navigate to event details
            if (result == true && context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(event: event),
                ),
              );
            }
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Event Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  event.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.event,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // Event Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 11,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.formattedDateTime,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 11,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${event.venue} - ${event.location}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
