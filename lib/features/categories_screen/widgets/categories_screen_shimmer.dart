import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trivia/core/constants/app_constant.dart';
import 'package:trivia/core/utils/size_config.dart';

class ShimmerLoadingScreen extends StatelessWidget {
  const ShimmerLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppConstant.shimmerBaseColor,
      highlightColor: AppConstant.shimmerHighlightColor,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: calcHeight(160)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  shimmerContainer(
                      height: calcHeight(130), width: calcWidth(100)),
                  shimmerContainer(
                      height: calcHeight(130), width: calcWidth(100)),
                  shimmerContainer(
                      height: calcHeight(130), width: calcWidth(100)),
                ],
              ),
              SizedBox(height: calcHeight(30)),
              shimmerContainer(height: calcHeight(200), width: double.infinity),
              SizedBox(height: calcHeight(20)),
              shimmerContainer(height: calcHeight(200), width: double.infinity),
              SizedBox(height: calcHeight(20)),
              shimmerContainer(height: calcHeight(200), width: double.infinity),
              SizedBox(height: calcHeight(20)),
              shimmerContainer(height: calcHeight(200), width: double.infinity),
            ],
          ),
        ),
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
