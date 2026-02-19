import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../di/injection.dart';
import '../../../../shared_services/presentation/cubit/application_flow_cubit.dart';
import '../../../../shared_services/presentation/cubit/application_flow_state.dart';
import '../../domain/static_form_models.dart';
import '../cubit/static_module_cubit.dart';
import '../cubit/static_module_state.dart';
import '../widgets/static_field_widget.dart';
import '../widgets/static_performance_panel.dart';

class StaticModulePage extends StatefulWidget {
  const StaticModulePage({
    required this.applicationId,
    required this.sectionId,
    super.key,
  });

  final String applicationId;
  final String sectionId;

  @override
  State<StaticModulePage> createState() => _StaticModulePageState();
}

class _StaticModulePageState extends State<StaticModulePage> {
  late final StaticModuleCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = sl<StaticModuleCubit>();
    _cubit.startMonitoring();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      () async {
        final ApplicationFlowCubit flowCubit = context
            .read<ApplicationFlowCubit>();
        await flowCubit.loadApplication(widget.applicationId);
        final ApplicationFlowState flowState = flowCubit.state;
        await _cubit.initialize(
          applicationId: widget.applicationId,
          sectionId: widget.sectionId,
          phase: flowState.currentPhase,
          sectionData: flowState.sectionData,
        );
      }();
    });
  }

  @override
  void dispose() {
    _cubit.stopMonitoring();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StaticModuleCubit>.value(
      value: _cubit,
      child: BlocConsumer<StaticModuleCubit, StaticModuleState>(
        listener: (BuildContext context, StaticModuleState state) {
          if (state.status == StaticModuleStatus.error &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (BuildContext context, StaticModuleState state) {
          final StaticModuleSnapshot? snapshot = state.snapshot;

          return Scaffold(
            appBar: AppBar(
              title: Text(snapshot?.schema.title ?? 'Static Module'),
              actions: <Widget>[
                TextButton.icon(
                  onPressed: state.status == StaticModuleStatus.saving
                      ? null
                      : () => context.read<StaticModuleCubit>().saveDraft(
                          applicationId: widget.applicationId,
                          sectionId: widget.sectionId,
                        ),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save Draft'),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      final result = await context
                          .read<StaticModuleCubit>()
                          .submit(applicationId: widget.applicationId);
                      if (!context.mounted) {
                        return;
                      }
                      final String message = result.success
                          ? 'Submitted. Next phase: ${result.nextPhase ?? ''}'
                          : 'Missing sections: ${(result.missingMandatorySections ?? <String>[]).join(', ')}';
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(SnackBar(content: Text(message)));
                    } catch (_) {}
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
            body: switch (state.status) {
              StaticModuleStatus.loading || StaticModuleStatus.initial =>
                const Center(child: CircularProgressIndicator()),
              _ =>
                snapshot == null
                    ? const Center(child: Text('No module data'))
                    : Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                            child: StaticPerformancePanel(
                              metrics: state.metrics,
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.all(16),
                              children: <Widget>[
                                ...snapshot.schema.cards.map(
                                  (StaticCardSchema card) => Card(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            card.title,
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 10),
                                          ...card.fields.map((
                                            StaticFieldSchema field,
                                          ) {
                                            final StaticFieldRuntimeState
                                            runtime =
                                                snapshot.fieldStates[field
                                                    .fieldId] ??
                                                const StaticFieldRuntimeState(
                                                  visible: true,
                                                  mandatory: false,
                                                  editable: true,
                                                  validation:
                                                      <String, dynamic>{},
                                                  options: <String>[],
                                                );
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: StaticFieldWidget(
                                                field: field,
                                                state: runtime,
                                                value: snapshot
                                                    .values[field.fieldId],
                                                onChanged: (dynamic next) {
                                                  context
                                                      .read<StaticModuleCubit>()
                                                      .onFieldChanged(
                                                        fieldId: field.fieldId,
                                                        value: next,
                                                      );
                                                  context
                                                      .read<StaticModuleCubit>()
                                                      .saveDraftDebounced(
                                                        applicationId: widget
                                                            .applicationId,
                                                        sectionId:
                                                            widget.sectionId,
                                                      );
                                                },
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (snapshot.actions.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    final action = snapshot.actions.first;
                                    context
                                        .read<StaticModuleCubit>()
                                        .executeAction(
                                          applicationId: widget.applicationId,
                                          actionId: action.actionId,
                                          payload: <String, dynamic>{
                                            action.triggerField: snapshot
                                                .values[action.triggerField],
                                          },
                                        );
                                  },
                                  icon: const Icon(Icons.bolt_rounded),
                                  label: Text(snapshot.actions.first.actionId),
                                ),
                              ),
                            ),
                        ],
                      ),
            },
          );
        },
      ),
    );
  }
}
