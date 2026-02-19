import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/injection.dart';
import '../../../../shared_services/presentation/cubit/application_flow_cubit.dart';
import '../../../../shared_services/presentation/cubit/application_flow_state.dart';
import '../../domain/entities/form_engine_entities.dart';
import '../cubit/form_engine_cubit.dart';
import '../cubit/form_engine_state.dart';
import '../widgets/dynamic_form_renderer.dart';
import '../widgets/performance_panel.dart';

class DynamicFormPage extends StatefulWidget {
  const DynamicFormPage({
    required this.applicationId,
    required this.sectionId,
    super.key,
  });

  final String applicationId;
  final String sectionId;

  @override
  State<DynamicFormPage> createState() => _DynamicFormPageState();
}

class _DynamicFormPageState extends State<DynamicFormPage> {
  late final FormEngineCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<FormEngineCubit>();
    _cubit.startMonitoring();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationFlowCubit>().loadApplication(
        widget.applicationId,
      );
    });
    _cubit.initialize(
      applicationId: widget.applicationId,
      sectionId: widget.sectionId,
    );
  }

  @override
  void dispose() {
    _cubit.stopMonitoring();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FormEngineCubit>.value(
      value: _cubit,
      child: BlocConsumer<FormEngineCubit, FormEngineState>(
        buildWhen: (FormEngineState previous, FormEngineState current) {
          // Rebuild only when necessary
          return previous.status != current.status ||
              previous.values != current.values ||
              previous.visibility != current.visibility ||
              previous.mandatory != current.mandatory ||
              previous.editable != current.editable ||
              previous.errors != current.errors ||
              previous.activeTile?.sectionId != current.activeTile?.sectionId;
        },
        listener: (BuildContext context, FormEngineState state) {
          if (state.status == FormEngineStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red.shade700,
              ));
          }
        },
        builder: (BuildContext context, FormEngineState state) {
          final ApplicationFlowState flowState = context
              .watch<ApplicationFlowCubit>()
              .state;
          final String? actionId = _resolveAction(flowState);
          return Scaffold(
            appBar: AppBar(
              title: Text(state.activeTile?.title ?? 'Dynamic Form'),
              actions: <Widget>[
                TextButton.icon(
                  onPressed: state.status == FormEngineStatus.saving
                      ? null
                      : () async {
                          final FormEngineCubit formCubit = context
                              .read<FormEngineCubit>();
                          final ApplicationFlowCubit flowCubit = context
                              .read<ApplicationFlowCubit>();
                          await formCubit.saveDraft(
                            applicationId: widget.applicationId,
                          );
                          if (!context.mounted) {
                            return;
                          }
                          await flowCubit.saveSectionDraft(
                            applicationId: widget.applicationId,
                            sectionId: widget.sectionId,
                            data: state.values,
                          );
                        },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Draft'),
                ),
                TextButton(
                  onPressed: () async {
                    final result = await context
                        .read<ApplicationFlowCubit>()
                        .submit(widget.applicationId);
                    if (!context.mounted || result == null) {
                      return;
                    }
                    final String message = result.success
                        ? 'Submitted. Next phase: ${result.nextPhase ?? ''}'
                        : 'Missing sections: ${(result.missingMandatorySections ?? <String>[]).join(', ')}';
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(SnackBar(content: Text(message)));
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
            body: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                  child: PerformancePanel(
                    metrics: state.metrics,
                    scenarioId: state.activeScenarioId,
                  ),
                ),
                if (state.scenarioIds.length > 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.scenarioIds
                            .map(
                              (String scenarioId) => ChoiceChip(
                                label: Text(scenarioId.replaceAll('_', ' ')),
                                selected: scenarioId == state.activeScenarioId,
                                onSelected: (_) {
                                  context
                                      .read<FormEngineCubit>()
                                      .switchScenario(
                                        applicationId: widget.applicationId,
                                        scenarioId: scenarioId,
                                      );
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                Expanded(
                  child: switch (state.status) {
                    FormEngineStatus.loading || FormEngineStatus.initial =>
                      const Center(child: CircularProgressIndicator()),
                    _ => DynamicFormRenderer(
                      tiles: state.activeTile == null
                          ? const <TileConfigEntity>[]
                          : <TileConfigEntity>[state.activeTile!],
                      values: state.values,
                      visibility: state.visibility,
                      mandatory: state.mandatory,
                      editable: state.editable,
                      errors: state.errors,
                      onFieldChanged: (String fieldId, dynamic value) {
                        context.read<FormEngineCubit>().onFieldChanged(
                          fieldId: fieldId,
                          value: value,
                        );
                        context.read<FormEngineCubit>().saveDraftDebounced(
                          applicationId: widget.applicationId,
                        );
                      },
                    ),
                  },
                ),
                if (actionId != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final dynamic triggerValue = _resolveTriggerValue(
                            flowState,
                            actionId: actionId,
                            localValues: state.values,
                          );
                          await context
                              .read<ApplicationFlowCubit>()
                              .executeAction(
                                applicationId: widget.applicationId,
                                actionId: actionId,
                                payload: <String, dynamic>{
                                  _resolveTriggerField(flowState, actionId):
                                      triggerValue,
                                },
                              );
                        },
                        icon: const Icon(Icons.bolt_rounded),
                        label: Text(actionId),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _resolveAction(ApplicationFlowState flowState) {
    final evaluate = flowState.evaluate;
    if (evaluate == null || evaluate.actions.isEmpty) {
      return null;
    }
    return evaluate.actions.first.actionId;
  }

  String _resolveTriggerField(ApplicationFlowState flowState, String actionId) {
    final evaluate = flowState.evaluate;
    if (evaluate == null) {
      return 'triggerField';
    }
    for (final action in evaluate.actions) {
      if (action.actionId == actionId) {
        return action.triggerField;
      }
    }
    return 'triggerField';
  }

  dynamic _resolveTriggerValue(
    ApplicationFlowState flowState, {
    required String actionId,
    required Map<String, dynamic> localValues,
  }) {
    final String triggerField = _resolveTriggerField(flowState, actionId);
    if (localValues.containsKey(triggerField)) {
      return localValues[triggerField];
    }
    return null;
  }
}
