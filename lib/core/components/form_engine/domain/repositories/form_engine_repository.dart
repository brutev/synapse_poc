import '../entities/form_engine_entities.dart';

abstract class FormEngineRepository {
  Future<List<TileConfigEntity>> loadTiles();

  Future<Map<String, dynamic>> loadDraft({
    required String applicationId,
    required String sectionId,
    required String scenarioId,
  });

  Future<void> saveDraft({
    required String applicationId,
    required String sectionId,
    required String scenarioId,
    required Map<String, dynamic> values,
  });
}
