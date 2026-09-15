import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import 'learning_module_card.dart';

class LearningModuleEntry {
  final String title;
  final String tagline;
  final IconData icon;
  final Color accent;
  final double progress;
  final VoidCallback onTap;

  const LearningModuleEntry({
    required this.title,
    required this.tagline,
    required this.icon,
    required this.accent,
    required this.progress,
    required this.onTap,
  });
}

/// 2×2 grid of module cards (matches the dashboard mockup).
class LearningModulesGrid extends StatelessWidget {
  final List<LearningModuleEntry> modules;

  const LearningModulesGrid({super.key, required this.modules});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: modules.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppConstants.cardGap,
        crossAxisSpacing: AppConstants.cardGap,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (_, i) {
        final m = modules[i];
        return LearningModuleCard(
          title: m.title,
          tagline: m.tagline,
          icon: m.icon,
          accent: m.accent,
          progress: m.progress,
          onTap: m.onTap,
        );
      },
    );
  }
}
