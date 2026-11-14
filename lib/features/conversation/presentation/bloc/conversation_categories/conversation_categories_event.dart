import 'package:equatable/equatable.dart';

abstract class ConversationCategoriesEvent extends Equatable {
  const ConversationCategoriesEvent();
  @override
  List<Object?> get props => [];
}

class LoadConversationCategories extends ConversationCategoriesEvent {
  const LoadConversationCategories();
}
