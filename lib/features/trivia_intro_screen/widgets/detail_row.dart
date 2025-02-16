import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/size_config.dart';

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final bool isLoading;

  const DetailRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: calcHeight(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
        children: [
          Icon(icon, color: iconColor ?? AppConstant.primaryColor),
          SizedBox(width: calcWidth(10)),
          Expanded(
            // Ensures text wraps instead of overflowing
            child: isLoading
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: double.infinity, // Take all available width
                      height: 20, // Match text height
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : Text(
                    text,
                    maxLines: 2, // Allows wrapping to two lines
                    overflow: TextOverflow.ellipsis, // Show "..." if needed
                    softWrap: true, // Enable text wrapping
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
          ),
        ],
      ),
    );
  }
}
