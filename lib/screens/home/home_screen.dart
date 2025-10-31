import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/event_model.dart';
import 'side_menu.dart';
import '../event/event_details_screen.dart';
import '../event/scan_not_available_screen.dart';
import '../event/offline_checkin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODAY'S EVENTS - Events happening today (for featured card at top)
  // Replace with actual data from Today's Events API
  final List<Event> _todayEvents = [
    Event(
      id: 'today-1',
      title: 'THE SHOGUN SHIFT...',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kulasingha Auditorium',
      location: 'Ananda College',
    ),
    Event(
      id: 'today-2',
      title: 'Marambari',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kulasingha Auditorium',
      location: 'Ananda College',
    ),
    Event(
      id: 'today-3',
      title: 'inthedark...',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kulasingha Auditorium',
      location: 'Ananda College',
    ),
  ];

  // UPCOMING EVENTS - Future events (for bottom list)
  // Replace with actual data from Upcoming Events API
  // Setting events to 7 days in the future to test "upcoming" behavior
  final List<Event> _upcomingEvents = [
    Event(
      id: 'upcoming-1',
      title: 'THE SHOGUN SHIFT 3.0',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime.now().add(const Duration(days: 7)),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
    ),
    Event(
      id: 'upcoming-2',
      title: 'Marambari',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime.now().add(const Duration(days: 8)),
      venue: 'Kulasingha Auditorium',
      location: 'Ananda College',
    ),
    Event(
      id: 'upcoming-3',
      title: 'Marambari',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime.now().add(const Duration(days: 9)),
      venue: 'Kulasingha Auditorium',
      location: 'Ananda College',
    ),
    Event(
      id: 'upcoming-4',
      title: 'Marambari',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime.now().add(const Duration(days: 10)),
      venue: 'Kulasingha Auditorium',
      location: 'Ananda College',
    ),
    Event(
      id: 'upcoming-5',
      title: 'Marambari',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime.now().add(const Duration(days: 11)),
      venue: 'Kulasingha Auditorium',
      location: 'Ananda College',
    ),
  ];

  // COMPLETED EVENTS
  final List<Event> _completedEvents = [
    Event(
      id: 'completed-1',
      title: 'RAN RASA SADE',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
    Event(
      id: 'completed-2',
      title: 'Oktoberfest Kandana',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
    Event(
      id: 'completed-3',
      title: 'Mervin',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
    Event(
      id: 'completed-4',
      title: 'Prabhanandaya',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
    Event(
      id: 'completed-5',
      title: 'Serened',
      imageUrl: 'assets/event_placeholder.png',
      dateTime: DateTime(2025, 10, 12, 18, 0),
      venue: 'Kularathna Auditorium',
      location: 'Ananda College',
      isCompleted: true,
    ),
  ];

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
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const SideMenu(),
      body: Column(
        children: [
          // App Bar
          SafeArea(
            bottom: false,
            child: _buildAppBar(context),
          ),

          // Scrollable content area
          Expanded(
            child: SingleChildScrollView(
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
                          color: Color(0xFF1F5CBF),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: Column(
                          children: [
                            const Text(
                              "Today's Events",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getTodayDate(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
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
                                .map((event) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: _buildTodayEventCard(event),
                                    ))
                                .toList(),
                          ),
                        ),

                      // No Events message overlapping blue and white sections
                      if (_todayEvents.isEmpty)
                        Positioned(
                          top: 160,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: SizedBox(
                              width: 250,
                              height: 150,
                              child: Image.asset(
                                'assets/No Events container.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        size: 50,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'No Today Events',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // Space for cards that extend beyond blue background
                  SizedBox(height: _todayEvents.isEmpty ? 80 : (_todayEvents.length * 80).toDouble()),

                  // Events Section Header with Tabs
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Events',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: const Color(0xFF1F5CBF),
                            unselectedLabelColor: const Color(0xFF6B7280),
                            labelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                            indicatorColor: const Color(0xFF1F5CBF),
                            indicatorWeight: 2,
                            tabs: const [
                              Tab(text: 'Upcoming events'),
                              Tab(text: 'Completed events'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Events List based on selected tab
                  Container(
                    color: Colors.white,
                    child: _tabController.index == 0
                        ? (_upcomingEvents.isEmpty
                            ? Container(
                                height: 300,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No events available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Column(
                                  children: _upcomingEvents
                                      .map((event) => _buildEventCard(event))
                                      .toList(),
                                ),
                              ))
                        : (_completedEvents.isEmpty
                            ? Container(
                                height: 300,
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No events available',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Column(
                                  children: _completedEvents
                                      .map((event) => _buildEventCard(event))
                                      .toList(),
                                ),
                              )),
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
      decoration: const BoxDecoration(
        color: Color(0xFF1F5CBF),
      ),
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
                  icon: const Icon(Icons.menu, color: Colors.white, size: 24),
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
              style: GoogleFonts.baloo2(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                        color: const Color(0xFF1F5CBF).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.event,
                        size: 30,
                        color: Color(0xFF1F5CBF),
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
                        const Icon(Icons.calendar_today, size: 11, color: Color(0xFF6B7280)),
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
                        const Icon(Icons.location_on, size: 11, color: Color(0xFF6B7280)),
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

  Widget _buildEventCard(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.15),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
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
                            color: const Color(0xFF1F5CBF).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.event,
                            size: 30,
                            color: Color(0xFF1F5CBF),
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
                        const Icon(Icons.calendar_today, size: 12, color: Color(0xFF6B7280)),
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
                        const Icon(Icons.location_on, size: 12, color: Color(0xFF6B7280)),
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

              // Arrow Icon with circular background
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
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
