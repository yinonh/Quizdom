import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:trivia/features/avatar_screen/view_model/avatar_screen_manager.dart';
import 'package:trivia/utalities/fluttermoji/fluttermojiCircleAvatar.dart';
import 'package:trivia/utalities/size_config.dart';

class EditAvatar extends ConsumerWidget {
  const EditAvatar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarScreenManagerProvider);
    final avatarNotifier = ref.read(avatarScreenManagerProvider.notifier);

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Hero(
            tag: "userAvatar",
            child: GestureDetector(
              onTap: () {
                if (avatarState.selectedImage != null) {
                  avatarNotifier.toggleShowTrashIcon();
                }
              },
              child: Stack(
                children: [
                  avatarState.selectedImage != null
                      ? CircleAvatar(
                          backgroundImage:
                              FileImage(avatarState.selectedImage!),
                          radius: calcWidth(70),
                        )
                      : FluttermojiCircleAvatar(
                          backgroundColor: Colors.grey[200],
                          radius: calcWidth(70),
                        ),
                  if (avatarState.showTrashIcon)
                    Container(
                      width: calcWidth(140),
                      height: calcWidth(140),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (avatarState.showTrashIcon)
            Positioned(
              bottom: 35,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  avatarNotifier.setImage(null);
                  avatarNotifier.toggleShowTrashIcon(false);
                },
              ),
            ),
          Positioned(
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () async {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.camera);
                    avatarNotifier.setImage(image);
                  },
                  icon: Icon(Icons.camera),
                ),
                SizedBox(width: calcWidth(70)),
                IconButton(
                  onPressed: () async {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    avatarNotifier.setImage(image);
                  },
                  icon: Icon(Icons.image),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
