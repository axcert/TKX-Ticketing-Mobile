import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tkx_ticketing/config/app_theme.dart';
import 'package:tkx_ticketing/widgets/custom_elevated_button.dart';

class ValidTicketScreen extends StatelessWidget {
  final Map<String, dynamic> ticketData;

  const ValidTicketScreen({super.key, required this.ticketData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${ticketData['recordId'] ?? 'N/A'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${ticketData['checkedCount'] ?? '325'}/${ticketData['totalCount'] ?? '500'}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                SizedBox(
                  height: 30,
                  width: 30,
                  child: ticketData['isVip']
                      ? SvgPicture.asset('assets/icons/vipp.svg')
                      : SvgPicture.asset('assets/icons/normal.svg'),
                ),
                Text(
                  ticketData['name'] ?? 'N/A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "Valid Ticket",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  ticketData['ticketId'] ?? 'N/A',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),

                Spacer(),
                Container(
                  height: 150,
                  width: 200,
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

                Spacer(),
                CustomElevatedButton(
                  backgroundColor: AppColors.background,
                  textColor: AppColors.textPrimary,

                  text: "Check-in",
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
