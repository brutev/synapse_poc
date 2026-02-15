import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/application_repository.dart';

class SaveDraftParams {
  const SaveDraftParams({
    required this.applicationId,
    required this.sectionId,
    required this.data,
  });

  final String applicationId;
  final String sectionId;
  final Map<String, dynamic> data;
}

class SaveDraftUseCase implements UseCase<void, SaveDraftParams> {
  SaveDraftUseCase(this._repository);

  final ApplicationRepository _repository;

  @override
  Future<Either<Failure, void>> call(SaveDraftParams params) {
    return _repository.saveDraft(
      applicationId: params.applicationId,
      sectionId: params.sectionId,
      data: params.data,
    );
  }
}
