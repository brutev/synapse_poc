import '../../../../constants/tile_configuration_json.dart';
import '../../domain/entities/form_engine_entities.dart';
import '../../domain/repositories/form_engine_repository.dart';
import '../datasources/form_engine_local_datasource.dart';
import '../models/form_engine_metadata_model.dart';

class FormEngineRepositoryImpl implements FormEngineRepository {
  FormEngineRepositoryImpl(this._localDataSource);

  final FormEngineLocalDataSource _localDataSource;

  @override
  Future<List<TileConfigEntity>> loadTiles() async {
    final FormEngineMetadataModel model = FormEngineMetadataModel.fromJson(
      tileConfigurationJson,
    );
    return model.tiles.map((TileConfigModel item) => item.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> loadDraft({
    required String applicationId,
    required String sectionId,
    required String scenarioId,
  }) {
    return _localDataSource.loadDraft(
      applicationId: applicationId,
      sectionId: sectionId,
      scenarioId: scenarioId,
    );
  }

  @override
  Future<void> saveDraft({
    required String applicationId,
    required String sectionId,
    required String scenarioId,
    required Map<String, dynamic> values,
  }) {
    return _localDataSource.saveDraft(
      applicationId: applicationId,
      sectionId: sectionId,
      scenarioId: scenarioId,
      values: values,
    );
  }
}
