import 'package:flutter/material.dart';
import 'package:trivia/features/profile_screen/widgets/trophys.dart';
import 'package:trivia/utility/app_constant.dart';
import 'package:trivia/utility/color_utility.dart';
import 'package:trivia/utility/size_config.dart';
import 'editable_field.dart';

class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isEditing = true;

    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      margin: const EdgeInsets.only(top: 60),
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(35.0),
          topRight: Radius.circular(35.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: calcWidth(20),
              right: calcWidth(20),
              top: calcHeight(100),
            ),
            child: const SizedBox(height: 5),
          ),
          Container(
            width: calcWidth(150),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppConstant.onPrimary.toColor(),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => const Icon(Icons.star, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (isEditing)
            EditableField(
              label: 'Username',
              controller: TextEditingController(),
            )
          else
            const SizedBox(height: 8),
          if (isEditing)
            EditableField(
              label: 'Email',
              controller: TextEditingController(),
            )
          else
            const SizedBox(height: 8),
          if (isEditing)
            EditableField(
              label: 'Password',
              controller: TextEditingController(),
              isPassword: true,
            ),
          const SizedBox(height: 32),
          const TrophySection(),
        ],
      ),
    );
  }
}
