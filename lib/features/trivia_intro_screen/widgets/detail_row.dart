import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/size_config.dart';

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const DetailRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: calcHeight(8)),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppConstant.primaryColor),
          SizedBox(width: calcWidth(10)),
          Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
