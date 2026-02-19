import 'package:equatable/equatable.dart';

import '../../domain/static_form_models.dart';

enum StaticModuleStatus { initial, loading, ready, saving, submitting, error }

class StaticModuleState extends Equatable {
  const StaticModuleState({
    this.status = StaticModuleStatus.initial,
    this.snapshot,
    this.metrics = const StaticFormMetrics(),
    this.errorMessage,
  });

  final StaticModuleStatus status;
  final StaticModuleSnapshot? snapshot;
  final StaticFormMetrics metrics;
  final String? errorMessage;

  StaticModuleState copyWith({
    StaticModuleStatus? status,
    StaticModuleSnapshot? snapshot,
    StaticFormMetrics? metrics,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StaticModuleState(
      status: status ?? this.status,
      snapshot: snapshot ?? this.snapshot,
      metrics: metrics ?? this.metrics,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, snapshot, metrics, errorMessage];
}
