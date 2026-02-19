import '../entities/form_engine_entities.dart';
import '../repositories/form_engine_repository.dart';

class LoadTilesUseCase {
  const LoadTilesUseCase(this._repository);

  final FormEngineRepository _repository;

  Future<List<TileConfigEntity>> call() => _repository.loadTiles();
}
