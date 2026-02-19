import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

abstract class FormEngineLocalDataSource {
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

class FormEngineLocalDataSourceImpl implements FormEngineLocalDataSource {
  FormEngineLocalDataSourceImpl();

  Database? _database;

  Future<Database> get _db async {
    if (_database != null) {
      return _database!;
    }
    final String databasesPath = await getDatabasesPath();
    final String dbPath = p.join(databasesPath, 'loan_poc_forms.db');
    _database = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (Database db, int version) async {
        await _createDraftTable(db);
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE form_drafts RENAME TO form_drafts_old');
          await _createDraftTable(db);
          await db.execute('''
            INSERT INTO form_drafts(
              application_id, section_id, scenario_id, field_id, value, updated_at
            )
            SELECT
              application_id, section_id, 'BASELINE', field_id, value, updated_at
            FROM form_drafts_old
          ''');
          await db.execute('DROP TABLE form_drafts_old');
        }
      },
    );
    return _database!;
  }

  Future<void> _createDraftTable(Database db) {
    return db.execute('''
      CREATE TABLE form_drafts (
        application_id TEXT NOT NULL,
        section_id TEXT NOT NULL,
        scenario_id TEXT NOT NULL,
        field_id TEXT NOT NULL,
        value TEXT,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY(application_id, section_id, scenario_id, field_id)
      )
    ''');
  }

  @override
  Future<Map<String, dynamic>> loadDraft({
    required String applicationId,
    required String sectionId,
    required String scenarioId,
  }) async {
    final Database db = await _db;
    final List<Map<String, Object?>> rows = await db.query(
      'form_drafts',
      where: 'application_id = ? AND section_id = ? AND scenario_id = ?',
      whereArgs: <Object?>[applicationId, sectionId, scenarioId],
    );

    final Map<String, dynamic> output = <String, dynamic>{};
    for (final Map<String, Object?> row in rows) {
      final String fieldId = (row['field_id'] as String?) ?? '';
      if (fieldId.isEmpty) {
        continue;
      }
      final String? encoded = row['value'] as String?;
      output[fieldId] = encoded == null ? null : jsonDecode(encoded);
    }
    return output;
  }

  @override
  Future<void> saveDraft({
    required String applicationId,
    required String sectionId,
    required String scenarioId,
    required Map<String, dynamic> values,
  }) async {
    final Database db = await _db;
    final Batch batch = db.batch();
    final int now = DateTime.now().millisecondsSinceEpoch;

    for (final MapEntry<String, dynamic> entry in values.entries) {
      batch.insert('form_drafts', <String, Object?>{
        'application_id': applicationId,
        'section_id': sectionId,
        'scenario_id': scenarioId,
        'field_id': entry.key,
        'value': jsonEncode(entry.value),
        'updated_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }
}
