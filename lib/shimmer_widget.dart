import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'app_strings.dart';

class SummaryShimmerLoading extends StatelessWidget {
  const SummaryShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, value, child) {
        final isRtl = AppStrings.isArabic;
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          direction: isRtl ? ShimmerDirection.rtl : ShimmerDirection.ltr,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLine(width: double.infinity),
                const SizedBox(height: 10),
                _buildLine(width: double.infinity),
                const SizedBox(height: 10),
                _buildLine(width: 250),
                const SizedBox(height: 10),
                _buildLine(width: double.infinity),
                const SizedBox(height: 10),
                _buildLine(width: 150),
                const SizedBox(height: 20),
                _buildLine(width: double.infinity),
                const SizedBox(height: 10),
                _buildLine(width: 200),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildLine({required double width}) {
    return Container(
      width: width,
      height: 14.0,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class CollectionsShimmerLoading extends StatelessWidget {
  const CollectionsShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppStrings.languageNotifier,
      builder: (context, value, child) {
        final isRtl = AppStrings.isArabic;
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          direction: isRtl ? ShimmerDirection.rtl : ShimmerDirection.ltr,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12.0),
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
        );
      }
    );
  }
}