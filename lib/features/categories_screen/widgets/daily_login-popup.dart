import 'package:flutter/material.dart';
import 'package:trivia/core/common_widgets/custom_button.dart';
import 'package:trivia/core/constants/app_constant.dart';

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
              "Daily Login Rewards",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // Subtitle
            const Text(
              "Claim your rewards by logging in daily!",
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
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
                    width: 90,
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Icon(
                          Icons.attach_money,
                          color: isClaimed ? Colors.white : Colors.black54,
                          size: 30,
                        ),
                        const SizedBox(height: 5),
                        // Day Number
                        Text(
                          "Day $day",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isClaimed ? Colors.white : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Reward Amount
                        Text(
                          "${rewards[index]} Coins",
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
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: streakDays / rewards.length,
              color: AppConstant.goldColor,
              minHeight: 15,
              borderRadius: BorderRadius.circular(20),
            ),
            const SizedBox(height: 10),
            CustomButton(
              text: "CLAIM",
              onTap: onClaim,
              color: AppConstant.secondaryColor,
            ),
            const SizedBox(height: 10),
            Text(
              streakDays < 5
                  ? "Keep login every day to get the rewards"
                  : "You've claimed all rewards!",
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
