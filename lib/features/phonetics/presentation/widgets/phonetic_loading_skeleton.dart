import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/skeleton_box.dart';

/// Three-box loading placeholder shown while the detail screen is fetching.
class PhoneticLoadingSkeleton extends StatelessWidget {
  const PhoneticLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.containerPadding,
        AppConstants.spacingMd,
        AppConstants.containerPadding,
        AppConstants.spacingLg,
      ),
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          SkeletonBox(height: 56, radius: AppConstants.radiusMd),
          SizedBox(height: AppConstants.spacingMd),
          SkeletonBox(height: 140, radius: AppConstants.radiusLg),
          SizedBox(height: AppConstants.spacingMd),
          SkeletonBox(height: 140, radius: AppConstants.radiusLg),
        ],
      ),
    );
  }
}
