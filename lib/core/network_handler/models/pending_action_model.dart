import 'package:uuid/uuid.dart';

/// Model for pending actions that need to be synced when online
class PendingActionModel {
  PendingActionModel({
    required this.id,
    required this.type, // 'save_draft', 'execute_action', 'submit'
    required this.applicationId,
    required this.data,
    required this.createdAt,
    this.syncedAt,
    this.attemptCount = 0,
  });

  final String id;
  final String type;
  final String applicationId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  DateTime? syncedAt;
  int attemptCount;

  factory PendingActionModel.fromJson(Map<String, dynamic> json) {
    return PendingActionModel(
      id: json['id'] as String,
      type: json['type'] as String,
      applicationId: json['applicationId'] as String,
      data: Map<String, dynamic>.from(json['data'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      syncedAt: json['syncedAt'] != null 
          ? DateTime.parse(json['syncedAt'] as String)
          : null,
      attemptCount: json['attemptCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'applicationId': applicationId,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
      'attemptCount': attemptCount,
    };
  }

  /// Create a copy with updated fields
  PendingActionModel copyWith({
    String? id,
    String? type,
    String? applicationId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? syncedAt,
    int? attemptCount,
  }) {
    return PendingActionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      applicationId: applicationId ?? this.applicationId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      syncedAt: syncedAt ?? this.syncedAt,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }

  /// Factory to create a new pending action
  factory PendingActionModel.create({
    required String type,
    required String applicationId,
    required Map<String, dynamic> data,
  }) {
    return PendingActionModel(
      id: const Uuid().v4(),
      type: type,
      applicationId: applicationId,
      data: data,
      createdAt: DateTime.now(),
    );
  }
}
