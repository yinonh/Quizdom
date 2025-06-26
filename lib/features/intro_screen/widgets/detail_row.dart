import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/utils/size_config.dart';

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
            child: isLoading
                ? Shimmer.fromColors(
                    baseColor: AppConstant.shimmerBaseColor,
                    highlightColor: AppConstant.shimmerHighlightColor,
                    child: Container(
                      width: double.infinity,
                      height: calcHeight(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  )
                : Text(
                    text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
          ),
        ],
      ),
    );
  }
}
