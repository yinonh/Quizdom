import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/constants/constant_strings.dart';
import 'package:trivia/core/utils/size_config.dart';

class DailyLoginPopupContent extends StatelessWidget {
  final int streakDays; // Current streak days
  final int startDay; // The first day the streak started
  final List<int> rewards; // Reward for each day
  final VoidCallback onClaim;

  const DailyLoginPopupContent({
    super.key,
    required this.streakDays,
    required this.startDay,
    required this.rewards,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    // ScrollController to manage horizontal scrolling
    final ScrollController scrollController = ScrollController(
      initialScrollOffset: (streakDays - 1) * 100.0, // Center the "Today" card
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppConstant.secondaryColor, AppConstant.primaryColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              Strings.dailyLoginRewards,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: calcHeight(10)),
            // Subtitle
            const Text(
              Strings.claimYourRewards,
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: calcHeight(20)),
            // Reward Days Display
            SingleChildScrollView(
              controller: scrollController, // Use custom scroll controller
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(rewards.length, (index) {
                  final day = startDay + index;
                  final isClaimed = index <= streakDays;
                  final isToday = index == streakDays;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: calcWidth(90),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isToday
                          ? AppConstant.highlightColor
                          : isClaimed
                              ? AppConstant.onPrimaryColor
                              : AppConstant.softHighlightColor,
                      borderRadius: BorderRadius.circular(10),
                      border: isToday
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Column(
                      spacing: calcHeight(5),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Icon(
                          Icons.attach_money,
                          color: isClaimed ? Colors.white : Colors.black54,
                          size: 30,
                        ),
                        // Day Number
                        Text(
                          "${Strings.day} $day",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isClaimed ? Colors.white : Colors.black54,
                          ),
                        ),
                        // Reward Amount
                        Text(
                          "${rewards[index]} ${Strings.coins}",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isClaimed ? Colors.white : Colors.black45,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: calcHeight(20)),
            LinearProgressIndicator(
              value: streakDays / rewards.length,
              color: AppConstant.goldColor,
              minHeight: 15,
              borderRadius: BorderRadius.circular(20),
            ),
            SizedBox(height: calcHeight(10)),
            CustomButton(
              text: Strings.claim,
              onTap: onClaim,
              color: AppConstant.secondaryColor,
            ),
            SizedBox(height: calcHeight(10)),
            Text(
              streakDays < 5 ? Strings.keepLogin : Strings.youClaimedAll,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
