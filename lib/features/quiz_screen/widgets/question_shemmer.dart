import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:Quizdom/core/constants/app_constant.dart';
import 'package:Quizdom/core/utils/size_config.dart';

class ShimmerLoadingQuestionWidget extends StatelessWidget {
  const ShimmerLoadingQuestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppConstant.shimmerBaseColor,
      highlightColor: AppConstant.shimmerHighlightColor,
      child: Column(
        children: [
          const Spacer(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: calcWidth(16)),
            child: shimmerContainer(
                height: calcHeight(20), width: double.infinity),
          ),
          SizedBox(height: calcHeight(20)),
          shimmerContainer(height: calcHeight(50), width: double.infinity),
          SizedBox(height: calcHeight(10)),
          shimmerContainer(height: calcHeight(50), width: double.infinity),
          SizedBox(height: calcHeight(10)),
          shimmerContainer(height: calcHeight(50), width: double.infinity),
          SizedBox(height: calcHeight(10)),
          shimmerContainer(height: calcHeight(50), width: double.infinity),
          const Spacer(),
          shimmerContainer(height: calcHeight(10), width: double.infinity),
          SizedBox(height: calcHeight(20)),
        ],
      ),
    );
  }

  Widget shimmerContainer({required double height, required double width}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
