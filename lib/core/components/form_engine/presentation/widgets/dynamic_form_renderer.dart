import 'package:flutter/material.dart';

import '../../domain/entities/form_engine_entities.dart';
import 'dynamic_card_widget.dart';

class DynamicFormRenderer extends StatelessWidget {
  const DynamicFormRenderer({
    required this.tiles,
    required this.values,
    required this.visibility,
    required this.mandatory,
    required this.editable,
    required this.errors,
    required this.onFieldChanged,
    super.key,
  });

  final List<TileConfigEntity> tiles;
  final Map<String, dynamic> values;
  final Map<String, bool> visibility;
  final Map<String, bool> mandatory;
  final Map<String, bool> editable;
  final Map<String, String?> errors;
  final void Function(String fieldId, dynamic value) onFieldChanged;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tiles.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int tileIndex) {
        final TileConfigEntity tile = tiles[tileIndex];
        return RepaintBoundary(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                tile.title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...tile.cards.map(
                (CardConfigEntity card) => DynamicCardWidget(
                  card: card,
                  values: values,
                  visibility: visibility,
                  mandatory: mandatory,
                  editable: editable,
                  errors: errors,
                  onFieldChanged: onFieldChanged,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
