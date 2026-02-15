import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../../core/widgets/loading_overlay.dart';
import '../../domain/entities/action_entity.dart';
import '../../domain/entities/evaluate_response_entity.dart';
import '../cubit/application_cubit.dart';
import '../cubit/application_state.dart';
import '../widgets/action_button_widget.dart';
import '../widgets/dynamic_section_widget.dart';

class ApplicationPage extends StatelessWidget {
  const ApplicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Origination')),
      body: BlocConsumer<ApplicationCubit, ApplicationState>(
        listener: (BuildContext context, ApplicationState state) {
          final String? message = state.errorMessage ?? state.infoMessage;
          if (message != null && message.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          }
        },
        builder: (BuildContext context, ApplicationState state) {
          return LoadingOverlay(
            isLoading: state.status == ApplicationStatus.loading,
            child: _Content(state: state),
          );
        },
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.state});

  final ApplicationState state;

  @override
  Widget build(BuildContext context) {
    final ApplicationCubit cubit = context.read<ApplicationCubit>();
    final EvaluateResponseEntity? evaluate = state.evaluate;

    if (evaluate == null) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: AppButton(
            label: 'Create Application',
            onPressed: cubit.loadApplication,
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Application: ${evaluate.applicationId}'),
              Text('Rule Version: ${evaluate.ruleVersion}'),
              Text('Phase: ${evaluate.phase}'),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: evaluate.sections.length,
            itemBuilder: (BuildContext context, int index) {
              final section = evaluate.sections[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DynamicSectionWidget(
                  section: section,
                  onFieldChanged: (String fieldId, Object? value) {
                    cubit.updateFieldValue(
                      sectionId: section.sectionId,
                      fieldId: fieldId,
                      value: value,
                    );
                  },
                  onSaveDraft: () =>
                      cubit.saveDraft(sectionId: section.sectionId),
                ),
              );
            },
          ),
        ),
        _ActionArea(actions: evaluate.actions),
      ],
    );
  }
}

class _ActionArea extends StatelessWidget {
  const _ActionArea({required this.actions});

  final List<ActionEntity> actions;

  @override
  Widget build(BuildContext context) {
    final ApplicationCubit cubit = context.read<ApplicationCubit>();
    final ApplicationState state = context.watch<ApplicationCubit>().state;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: <Widget>[
          ...actions.map(
            (ActionEntity action) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ActionButtonWidget(
                action: action,
                onTap: () {
                  final String? applicationId = state.applicationId;
                  if (applicationId == null) {
                    return;
                  }

                  final Object? triggerValue = _resolveTriggerValue(
                    state.evaluate,
                    state.draftSectionData,
                    action.triggerField,
                  );

                  cubit.executeAction(
                    actionId: action.actionId,
                    payload: <String, dynamic>{
                      action.triggerField: triggerValue,
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          AppButton(
            label: 'Refresh Evaluate',
            onPressed: cubit.refreshEvaluate,
          ),
          const SizedBox(height: 8),
          AppButton(label: 'Submit', onPressed: cubit.submit),
        ],
      ),
    );
  }

  Object? _resolveTriggerValue(
    EvaluateResponseEntity? evaluate,
    Map<String, Map<String, dynamic>> draftData,
    String fieldId,
  ) {
    for (final Map<String, dynamic> sectionData in draftData.values) {
      if (sectionData.containsKey(fieldId)) {
        return sectionData[fieldId];
      }
    }

    if (evaluate == null) {
      return null;
    }

    for (final section in evaluate.sections) {
      for (final field in section.fields) {
        if (field.fieldId == fieldId) {
          return field.value;
        }
      }
    }

    return null;
  }
}
