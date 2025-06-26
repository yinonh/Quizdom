import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Quizdom/core/common_widgets/custom_when.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/constants/constant_strings.dart';
import 'package:Quizdom/core/utils/fluttermoji/fluttermoji_circle_avatar.dart';
import 'package:Quizdom/core/utils/size_config.dart';
import 'package:Quizdom/features/avatar_screen/view_model/avatar_screen_manager.dart';

class EditAvatar extends ConsumerWidget {
  const EditAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final avatarState = ref.watch(avatarScreenManagerProvider);
    final avatarNotifier = ref.read(avatarScreenManagerProvider.notifier);

    return Center(
      child: avatarState.customWhen(
        data: (state) => Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Hero(
              tag: Strings.userAvatarTag,
              child: GestureDetector(
                onTap: () {
                  if (state.showImage) {
                    avatarNotifier.toggleShowTrashIcon();
                  }
                },
                child: Stack(
                  children: [
                    if (state.showImage)
                      (state.selectedImage != null
                          ? CircleAvatar(
                              backgroundImage: FileImage(state.selectedImage!)
                                  as ImageProvider,
                              radius: calcWidth(70),
                            )
                          : CachedNetworkImage(
                              imageUrl: state.currentImage!,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: AppConstant.shimmerBaseColor,
                                highlightColor:
                                    AppConstant.shimmerHighlightColor,
                                child: CircleAvatar(
                                  backgroundColor: AppConstant.shimmerBaseColor,
                                  radius: calcWidth(70),
                                ),
                              ),
                              imageBuilder: (context, image) => CircleAvatar(
                                backgroundImage: image,
                                radius: calcWidth(70),
                              ),
                            ))
                    else
                      FluttermojiCircleAvatar(
                        backgroundColor: AppConstant.softHighlightColor,
                        radius: calcWidth(70),
                      ),
                    if (state.showTrashIcon)
                      Container(
                        width: calcWidth(140),
                        height: calcWidth(140),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (state.showTrashIcon)
              Positioned(
                bottom: 35,
                child: IconButton(
                  icon: Icon(Icons.delete,
                      color: Colors.white.withValues(alpha: 0.5)),
                  onPressed: () {
                    avatarNotifier.switchImage(null);
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
                      avatarNotifier.switchImage(image);
                    },
                    icon: Container(
                      width: calcWidth(45.0),
                      height: calcHeight(45.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.camera,
                        size: 30,
                        color: AppConstant.onPrimaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: calcWidth(55)),
                  IconButton(
                    onPressed: () async {
                      final image = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      avatarNotifier.switchImage(image);
                    },
                    icon: Container(
                      width: calcWidth(45.0),
                      height: calcHeight(45.0),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 30,
                        color: AppConstant.onPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
