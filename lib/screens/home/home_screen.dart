import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/models/event_model.dart';
import 'package:tkx_ticketing/providers/event_provider.dart';
import 'package:tkx_ticketing/screens/event/event_details_screen.dart';
import 'package:tkx_ticketing/screens/event/offline_checkin_screen.dart';
import 'package:tkx_ticketing/screens/event/scan_not_available_screen.dart';
import 'package:tkx_ticketing/widgets/offline_indicator.dart';
import 'side_menu.dart';
import 'tabs/upcoming_events_tab.dart';
import 'tabs/completed_events_tab.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Rebuild when tab changes
    });

    // Fetch events when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<EventProvider>(context, listen: false).fetchEvents();
      }
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
      drawer: const Drawer(child: SideMenu()),
      body: Consumer<EventProvider>(
        builder: (context, eventProvider, child) {
          final todayEvents = eventProvider.todayEvents;
          final upcomingEvents = eventProvider.upcomingEvents;
          final completedEvents = eventProvider.completedEvents;
          final isLoading = eventProvider.isLoading;

          // Show full-screen loading on initial fetch (no data yet)
          if (isLoading &&
              todayEvents.isEmpty &&
              upcomingEvents.isEmpty &&
              completedEvents.isEmpty) {
            return Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                const OfflineIndicator(),
                _buildAppBar(context, eventProvider.organizerName),
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading events...',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            onRefresh: () => eventProvider.refreshEvents(),
            child: Column(
              children: [
                // Offline Indicator

                // App Bar
                SizedBox(height: MediaQuery.of(context).padding.top),
                const OfflineIndicator(),
                _buildAppBar(context, eventProvider.organizerName),

                // Scrollable content area
                Expanded(
                  child: Column(
                    children: [
                      // Blue background with cards on top
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,

                        // ... (cutting out middle part to avoid finding issues, I will target specific blocks if possible)
                        // Wait, replace_file_content handles a contiguous block.
                        // I have two calls to _buildAppBar separated by lines.
                        // And the definition is further down.
                        // I should use MULTI_REPLACE.
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                        color: AppColors.textWhite,
                                        fontSize: 36,
                                        fontFamily:
                                            GoogleFonts.plusJakartaSans()
                                                .fontFamily,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _getTodayDate(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayMedium!
                                      .copyWith(
                                        color: AppColors.divider,
                                        fontSize: 16,
                                        fontFamily:
                                            GoogleFonts.plusJakartaSans()
                                                .fontFamily,
                                      ),
                                ),
                              ],
                            ),
                          ),

                          // Today's Event Cards positioned on top
                          if (todayEvents.isNotEmpty)
                            Positioned(
                              top: 140,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 110,
                                child: PageView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  controller: PageController(
                                    viewportFraction: 1.0,
                                  ),
                                  itemCount: todayEvents.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: _buildTodayEventCard(
                                        todayEvents[index],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                          // Loading indicator for today's events
                          if (isLoading && todayEvents.isEmpty)
                            const Positioned(
                              top: 160,
                              left: 0,
                              right: 0,
                              child: SizedBox(
                                height: 150,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ),
                            ),

                          // No Events message overlapping blue and white sections
                          if (!isLoading && todayEvents.isEmpty)
                            Positioned(
                              top: 160,
                              left: 0,
                              right: 0,
                              child: SizedBox(
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
                      // Fixed height: 120 (card container) - 60 (overlap) = 60. Using 70 for safety.
                      SizedBox(height: todayEvents.isEmpty ? 100 : 70),

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
                      Expanded(
                        child: Container(
                          color: AppColors.surface,
                          child: _tabController.index == 0
                              ? UpcomingEventsTab(events: upcomingEvents)
                              : CompletedEventsTab(events: completedEvents),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String? organizerName) {
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
              organizerName ?? '',
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
            // Show offline check-in preparation screen
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
