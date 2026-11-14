import 'package:equatable/equatable.dart';

import '../../../domain/entities/conversation_category.dart';

sealed class ConversationCategoriesState extends Equatable {
  const ConversationCategoriesState();
  @override
  List<Object?> get props => [];
}

class ConversationCategoriesInitial extends ConversationCategoriesState {
  const ConversationCategoriesInitial();
}

class ConversationCategoriesLoading extends ConversationCategoriesState {
  const ConversationCategoriesLoading();
}

class ConversationCategoriesLoaded extends ConversationCategoriesState {
  final List<ConversationCategory> categories;
  const ConversationCategoriesLoaded({required this.categories});
  @override
  List<Object?> get props => [categories];
}

class ConversationCategoriesError extends ConversationCategoriesState {
  final String message;
  const ConversationCategoriesError({required this.message});
  @override
  List<Object?> get props => [message];
}
