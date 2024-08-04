import 'package:flutter/material.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  const CustomAppBar(
      {required this.title, this.leading, this.actions, super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: preferredSize.height + 100, // Add height to show the curve
          decoration: BoxDecoration(
            color: AppConstant.primaryColor.toColor(),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(7),
            ),
          ),
        ),
        AppBar(
          actions: actions ?? [],
          leading: leading ??
              (Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                  : null),
          backgroundColor: Colors.transparent, // Set to transparent
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: Navigator.canPop(context) ? 50 : 0,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
