import 'package:equatable/equatable.dart';

class FieldEntity extends Equatable {
  const FieldEntity({
    required this.fieldId,
    required this.type,
    required this.value,
    required this.mandatory,
    required this.editable,
    required this.visible,
    required this.validation,
  });

  final String fieldId;
  final String type;
  final Object? value;
  final bool mandatory;
  final bool editable;
  final bool visible;
  final Map<String, dynamic> validation;

  FieldEntity copyWith({Object? value = _sentinel, bool? editable}) {
    return FieldEntity(
      fieldId: fieldId,
      type: type,
      value: identical(value, _sentinel) ? this.value : value,
      mandatory: mandatory,
      editable: editable ?? this.editable,
      visible: visible,
      validation: validation,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        fieldId,
        type,
        value,
        mandatory,
        editable,
        visible,
        validation,
      ];
}

const Object _sentinel = Object();
