import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingQuestionWidget extends StatelessWidget {
  const ShimmerLoadingQuestionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: shimmerContainer(height: 20, width: double.infinity),
          ),
          const SizedBox(height: 20),
          shimmerContainer(height: 50, width: double.infinity),
          const SizedBox(height: 10),
          shimmerContainer(height: 50, width: double.infinity),
          const SizedBox(height: 10),
          shimmerContainer(height: 50, width: double.infinity),
          const SizedBox(height: 10),
          shimmerContainer(height: 50, width: double.infinity),
          const Spacer(),
          shimmerContainer(height: 10, width: double.infinity),
          const SizedBox(height: 20),
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
