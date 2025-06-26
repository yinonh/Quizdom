import 'package:flutter/material.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class TotalScore extends StatelessWidget {
  final int score;
  const TotalScore({required this.score, super.key});

  Widget _buildConfettiElement({
    required Color color,
    required double size,
    required double rotation,
  }) {
    return Transform.rotate(
      angle: rotation * (3.14159 / 180),
      child: Icon(
        Icons.star,
        color: color,
        size: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: calcWidth(20)),
      child: SizedBox(
        width: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Main background with custom shape
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: calcHeight(50),
                bottom: calcHeight(25),
                left: calcWidth(20),
                right: calcWidth(20),
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(height: calcHeight(30)),
                  Text(
                    score.toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: AppConstant.onPrimaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: calcHeight(8)),
                  const Text(
                    Strings.totalScore,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Crown effect at the top
            Positioned(
              top: -calcHeight(25),
              child: Container(
                height: calcHeight(75),
                width: calcWidth(170),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppConstant.secondaryColor,
                      AppConstant.primaryColor,
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppConstant.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Trophy icon
                    const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 38,
                    ),

                    // Decorative elements
                    Positioned(
                      top: calcHeight(15),
                      left: calcWidth(30),
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: calcHeight(15),
                      right: calcWidth(30),
                      child: Container(
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confetti decorations
            Positioned(
              bottom: calcHeight(10),
              right: calcWidth(20),
              child: _buildConfettiElement(
                color: AppConstant.goldColor.withValues(alpha: 0.6),
                size: 70,
                rotation: 15,
              ),
            ),
            Positioned(
              top: calcHeight(30),
              left: calcWidth(25),
              child: _buildConfettiElement(
                color: AppConstant.highlightColor.withValues(alpha: 0.6),
                size: 90,
                rotation: -25,
              ),
            ),
            Positioned(
              top: calcHeight(30),
              right: calcWidth(40),
              child: _buildConfettiElement(
                color: AppConstant.secondaryColor.withValues(alpha: 0.6),
                size: 60,
                rotation: 40,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
