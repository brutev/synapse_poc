import 'package:equatable/equatable.dart';

import 'field_entity.dart';

class SectionEntity extends Equatable {
  const SectionEntity({
    required this.sectionId,
    required this.mandatory,
    required this.editable,
    required this.visible,
    required this.status,
    required this.fields,
  });

  final String sectionId;
  final bool mandatory;
  final bool editable;
  final bool visible;
  final String status;
  final List<FieldEntity> fields;

  SectionEntity copyWith({List<FieldEntity>? fields}) {
    return SectionEntity(
      sectionId: sectionId,
      mandatory: mandatory,
      editable: editable,
      visible: visible,
      status: status,
      fields: fields ?? this.fields,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        sectionId,
        mandatory,
        editable,
        visible,
        status,
        fields,
      ];
}
