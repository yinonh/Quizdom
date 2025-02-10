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
        children: [
          Icon(icon, color: iconColor ?? AppConstant.primaryColor),
          SizedBox(width: calcWidth(10)),
          if (isLoading)
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: calcWidth(250), // Approximate width for text
                height: 20, // Match text height
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            )
          else
            Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
        ],
      ),
    );
  }
}
