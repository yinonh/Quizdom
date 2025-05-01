import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:trivia/core/constants/app_constant.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? leading;
  final List<Widget>? actions;
  final void Function()? onBack;

  const CustomAppBar(
      {this.title, this.leading, this.actions, this.onBack, super.key});

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
              (GoRouter.of(context).canPop()
                  ? IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (onBack != null) {
                          onBack!();
                        }
                        context.pop();
                      })
                  : null),
          backgroundColor: Colors.transparent,
          // Set to transparent
          elevation: 0,
          title: FittedBox(
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                if (title != null)
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                SizedBox(
                  width: GoRouter.of(context).canPop() ? 50 : 0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
