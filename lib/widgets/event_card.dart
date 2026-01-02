import 'package:flutter/material.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/models/event_model.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final Function()? onTap;

  EventCard({super.key, required this.event, this.onTap});

  Map<String, dynamic> _getEventStatus() {
    if (event.isUpcoming) {
      return {
        'text': 'Upcoming',
        'color': const Color.fromARGB(255, 216, 208, 136),
        'borderColor': AppColors.warning,
      };
    } else if (event.isOngoing) {
      return {
        'text': 'Ongoing',
        'color': const Color.fromARGB(255, 159, 237, 160),
        'borderColor': AppColors.success,
      };
    } else {
      return {
        'text': 'Completed',
        'color': const Color.fromARGB(255, 149, 200, 242),
        'borderColor': AppColors.info,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Allow children to overflow the Stack bounds
      children: [
        Container(
          margin: const EdgeInsets.only(
            bottom: 12,
            top: 8,
          ), // Added top margin for status badge
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: onTap != null || event.isUpcoming
                ? Border.all(
                    color: AppColors.shadow.withValues(alpha: 0.15),
                    width: 1,
                  )
                : null,
            boxShadow: onTap != null || event.isUpcoming
                ? [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  _buildEventImage(),
                  const SizedBox(width: 12),
                  Expanded(child: _buildEventDetails()),
                  onTap != null ? _buildArrowIcon() : const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ),
        onTap == null
            ? Positioned(
                right: 20, // Position from right side for better alignment
                top: -5, // Align with top of the card
                child: Builder(
                  builder: (context) {
                    final status = _getEventStatus();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: status['color'] as Color,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: status['borderColor'] as Color,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status['text'] as String,
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    );
                  },
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildEventImage() {
    final imageUrl = event.imageUrl.trim();
    final isNetworkImage = imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://');

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: isNetworkImage
          ? Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageFallback();
              },
            )
          : Image.asset(
              imageUrl.isNotEmpty ? imageUrl : 'assets/event_placeholder.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImageFallback();
              },
            ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF1F5CBF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.event, size: 30, color: Color(0xFF1F5CBF)),
    );
  }

  Widget _buildEventDetails() {
    return Column(
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
              size: 12,
              color: Color(0xFF6B7280),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                event.formattedDateTime,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
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
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArrowIcon() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: Color(0xFFF3F4F6),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Color(0xFF6B7280),
      ),
    );
  }
}
