import 'package:injectable/injectable.dart';

import '../model/language_model.dart';
import '../repository/language_repository.dart';

@Injectable()
class ObserveLanguageUsecase {
  final LanguageRepository _repository;

  ObserveLanguageUsecase(this._repository);

  Stream<LanguageModel> execute() {
    return _repository.observeLanguageChanges();
  }
}

