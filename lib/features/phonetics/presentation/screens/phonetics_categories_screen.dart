import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_english_app/base/common_widget/custom_back_button.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/bayan_colors.dart';
import '../../../../core/theme/bayan_typography.dart';
import '../../../../di/di.dart';
import '../../../../shared/widgets/error_state_view.dart';
import '../../domain/entities/phonetic_category.dart';
import '../bloc/phonetic_categories/phonetic_categories_bloc.dart';
import '../bloc/phonetic_categories/phonetic_categories_event.dart';
import '../bloc/phonetic_categories/phonetic_categories_state.dart';
import '../widgets/learning_tip_card.dart';
import '../widgets/phonetic_category_card.dart';
import '../widgets/phonetics_page_header.dart';

class PhoneticsCategoriesScreen extends StatelessWidget {
  const PhoneticsCategoriesScreen({super.key});

  static IconData _iconFor(PhoneticCategory cat) {
    switch (cat.id) {
      case 1:
        return Icons.abc_rounded;
      case 2:
        return Icons.record_voice_over_rounded;
      case 3:
        return Icons.music_note_rounded;
      case 4:
        return Icons.menu_book_rounded;
      default:
        return Icons.record_voice_over_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PhoneticCategoriesBloc>()..add(const LoadPhoneticCategories()),
      child: Scaffold(
        backgroundColor: BayanColors.background,
        appBar: AppBar(
          backgroundColor: BayanColors.background,
          leading: CustomBackButton(onClicked: (){
            context.pop();
          }),
          title: Text(
            'Phonetics',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BayanTypography.headlineMedium.copyWith(color: BayanColors.onSurface, fontWeight: FontWeight.w700),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<PhoneticCategoriesBloc, PhoneticCategoriesState>(
            builder: (context, state) {
              final bloc = context.read<PhoneticCategoriesBloc>();
              final level = bloc.level;
              return switch (state) {
                PhoneticCategoriesInitial() ||
                PhoneticCategoriesLoading() => const Center(child: CircularProgressIndicator()),
                PhoneticCategoriesError(:final message) => ErrorStateView(
                  message: message,
                  onRetry: () => bloc.add(const LoadPhoneticCategories()),
                ),
                PhoneticCategoriesLoaded(:final categories, :final topicIdsByCategory, :final progress) => ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.containerPadding,
                    AppConstants.spacingLg,
                    AppConstants.containerPadding,
                    AppConstants.spacingLg,
                  ),
                  children: [
                    PhoneticsPageHeader(level: level),
                    const SizedBox(height: AppConstants.spacingLg),
                    for (final c in categories) ...[
                      PhoneticCategoryCard(
                        category: c,
                        icon: _iconFor(c),
                        progress: progress.categoryProgress(topicIdsByCategory[c.id] ?? const []),
                        onTap: () => context.push('/phonetics/${c.id}', extra: c.title),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                    ],
                    const SizedBox(height: AppConstants.spacingSm),
                    LearningTipCard(level: level),
                  ],
                ),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ),
    );
  }
}
