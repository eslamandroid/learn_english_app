import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/usecases/get_conversation_categories.dart';
import 'conversation_categories_event.dart';
import 'conversation_categories_state.dart';

@injectable
class ConversationCategoriesBloc extends Bloc<ConversationCategoriesEvent,
    ConversationCategoriesState> {
  final GetConversationCategories _getCategories;

  ConversationCategoriesBloc(this._getCategories)
      : super(const ConversationCategoriesInitial()) {
    on<LoadConversationCategories>(_onLoad);
  }

  Future<void> _onLoad(
    LoadConversationCategories event,
    Emitter<ConversationCategoriesState> emit,
  ) async {
    emit(const ConversationCategoriesLoading());
    final result = await _getCategories.execute();
    result.fold(
      (e) => emit(ConversationCategoriesError(message: e.toString())),
      (categories) =>
          emit(ConversationCategoriesLoaded(categories: categories)),
    );
  }
}
