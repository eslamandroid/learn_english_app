import 'package:equatable/equatable.dart';

import '../../../../progress/domain/entities/phonetics_progress.dart';
import '../../../domain/entities/phonetic_category.dart';

abstract class PhoneticCategoriesState extends Equatable {
  const PhoneticCategoriesState();

  @override
  List<Object?> get props => [];
}

class PhoneticCategoriesInitial extends PhoneticCategoriesState {
  const PhoneticCategoriesInitial();
}

class PhoneticCategoriesLoading extends PhoneticCategoriesState {
  const PhoneticCategoriesLoading();
}

class PhoneticCategoriesLoaded extends PhoneticCategoriesState {
  final List<PhoneticCategory> categories;

  /// `categoryId → ordered list of topic ids in that category`. Used by the
  /// card to count completed topics.
  final Map<int, List<int>> topicIdsByCategory;
  final PhoneticsProgress progress;

  const PhoneticCategoriesLoaded({
    required this.categories,
    this.topicIdsByCategory = const {},
    this.progress = PhoneticsProgress.empty,
  });

  PhoneticCategoriesLoaded copyWith({
    List<PhoneticCategory>? categories,
    Map<int, List<int>>? topicIdsByCategory,
    PhoneticsProgress? progress,
  }) {
    return PhoneticCategoriesLoaded(
      categories: categories ?? this.categories,
      topicIdsByCategory: topicIdsByCategory ?? this.topicIdsByCategory,
      progress: progress ?? this.progress,
    );
  }

  @override
  List<Object?> get props => [categories, topicIdsByCategory, progress];
}

class PhoneticCategoriesError extends PhoneticCategoriesState {
  final String message;
  const PhoneticCategoriesError({required this.message});

  @override
  List<Object?> get props => [message];
}
