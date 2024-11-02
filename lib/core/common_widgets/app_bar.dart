import 'package:flutter/material.dart';
import 'package:trivia/core/constants/app_constant.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final void Function()? onBack;

  const CustomAppBar(
      {required this.title,
      this.leading,
      this.actions,
      this.onBack,
      super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: preferredSize.height,
          decoration: const BoxDecoration(
            color: AppConstant.primaryColor,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(7),
            ),
          ),
        ),
        AppBar(
          scrolledUnderElevation: 0,
          actions: actions ?? [],
          leading: leading ??
              (Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (onBack != null) {
                          onBack!();
                        }
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
                style: const TextStyle(color: Colors.white),
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
