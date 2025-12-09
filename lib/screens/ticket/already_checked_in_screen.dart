import 'package:flutter/material.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/widgets/custom_elevated_button.dart';

class AlreadyCheckedInScreen extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const AlreadyCheckedInScreen({super.key, required this.ticketData});

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
                image: AssetImage('assets/check-in.png'),
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
                      '#${ticketData['recordId'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: AppColors.background,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${ticketData['checkedCount'] ?? '325'}/${ticketData['totalCount'] ?? '500'}',
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
                            image: ticketData['isVip']
                                ? AssetImage('assets/vip.png')
                                : AssetImage('assets/normal.png'),
                            alignment: Alignment.center,
                          ),
                        ),
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                      Text(
                        ticketData['name'] ?? 'N/A',
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
                        "Already\nChecked-In",
                        style: Theme.of(context).textTheme.displayLarge!
                            .copyWith(
                              fontSize: 40,
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        ticketData['ticketId'] ?? 'N/A',
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
                          ticketData['seatNo'] ?? 'N/A',
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

                CustomElevatedButton(
                  backgroundColor: AppColors.background,
                  textColor: AppColors.textPrimary,
                  text: "Okay",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
