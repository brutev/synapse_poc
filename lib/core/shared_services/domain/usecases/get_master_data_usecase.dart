import '../repositories/shared_repository.dart';

class GetMasterDataUseCase {
  const GetMasterDataUseCase(this._repository);

  final SharedRepository _repository;

  Future<List<String>> call() => _repository.getMasterData();
}
