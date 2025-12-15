import 'package:flutter/material.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';

class OfflineIndicator extends StatelessWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        if (connectivityService.isOffline) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: AppColors.error,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, color: AppColors.textWhite, size: 16),
                const SizedBox(width: 8),
                Text(
                  'No internet connection',
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontSize: 13,
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
