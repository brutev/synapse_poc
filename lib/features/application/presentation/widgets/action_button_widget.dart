import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../domain/entities/action_entity.dart';

class ActionButtonWidget extends StatelessWidget {
  const ActionButtonWidget({
    required this.action,
    required this.onTap,
    super.key,
  });

  final ActionEntity action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppButton(label: action.actionId, onPressed: onTap);
  }
}
