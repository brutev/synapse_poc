import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../shared_services/domain/entities/los_entities.dart';
import '../shared_services/presentation/cubit/application_flow_cubit.dart';
import '../shared_services/presentation/cubit/application_flow_state.dart';

class ModuleBoardPage extends StatefulWidget {
  const ModuleBoardPage({required this.applicationId, super.key});

  final String applicationId;

  @override
  State<ModuleBoardPage> createState() => _ModuleBoardPageState();
}

class _ModuleBoardPageState extends State<ModuleBoardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ApplicationFlowCubit>().loadApplication(
        widget.applicationId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApplicationFlowCubit, ApplicationFlowState>(
      listener: (BuildContext context, ApplicationFlowState state) {
        if (state.status == ApplicationFlowStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (BuildContext context, ApplicationFlowState state) {
        final EvaluateResponseEntity? evaluate = state.evaluate;
        final List<_ModuleViewData> moduleData = _buildModuleData(evaluate);

        final int completedCount = moduleData
            .where((item) => item.state.status == 'COMPLETED')
            .length;
        final int totalCount = moduleData.length;
        final double progress = totalCount == 0
            ? 0
            : completedCount / totalCount;

        final List<_ModuleViewData> mandatoryModules = moduleData
            .where((item) => item.state.mandatory)
            .toList();
        final List<_ModuleViewData> optionalModules = moduleData
            .where((item) => !item.state.mandatory)
            .toList();

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Module Board'),
              bottom: const TabBar(
                tabs: <Tab>[
                  Tab(text: 'Mandatory'),
                  Tab(text: 'Optional'),
                ],
              ),
            ),
            body: switch (state.status) {
              ApplicationFlowStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
              _ => Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: _BoardSummary(
                      applicationId: widget.applicationId,
                      completedCount: completedCount,
                      totalCount: totalCount,
                      progress: progress,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: <Widget>[
                        _ModuleGrid(
                          applicationId: widget.applicationId,
                          data: mandatoryModules,
                        ),
                        _ModuleGrid(
                          applicationId: widget.applicationId,
                          data: optionalModules,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            },
          ),
        );
      },
    );
  }

  List<_ModuleViewData> _buildModuleData(EvaluateResponseEntity? evaluate) {
    if (evaluate == null) {
      return loanModules
          .map(
            (ModuleTileConfig module) => _ModuleViewData(
              config: module,
              state: const _ModuleState(
                status: 'PENDING',
                mandatory: false,
                locked: false,
                visible: true,
              ),
            ),
          )
          .toList();
    }

    final Map<String, ModuleTileConfig> uiBySection =
        <String, ModuleTileConfig>{for (final m in loanModules) m.sectionId: m};

    final List<_ModuleViewData> data = <_ModuleViewData>[];
    int index = 1;

    for (final EvaluateSectionEntity section in evaluate.sections) {
      final ModuleTileConfig config =
          uiBySection[section.sectionId] ??
          ModuleTileConfig(
            sectionId: section.sectionId,
            code: 'S$index',
            title: section.sectionId,
            stage: evaluate.phase,
          );

      final bool anyEditableField = section.fields.any(
        (EvaluateFieldEntity field) => field.editable,
      );

      data.add(
        _ModuleViewData(
          config: config,
          state: _ModuleState(
            status: section.status,
            mandatory: section.mandatory,
            locked: !section.editable && !anyEditableField,
            visible: section.visible,
          ),
        ),
      );
      index += 1;
    }

    return data.where((item) => item.state.visible).toList();
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.applicationId, required this.data});

  final String applicationId;
  final List<_ModuleViewData> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('No modules available'));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.25,
      ),
      itemBuilder: (BuildContext context, int index) {
        final _ModuleViewData moduleData = data[index];
        return _ModuleBoardTile(
          data: moduleData,
          onTap: () {
            if (moduleData.state.locked) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Module is currently locked by rule evaluation',
                    ),
                  ),
                );
              return;
            }
            context.push(
              '/proposal/$applicationId/module/${moduleData.config.sectionId}',
            );
          },
        );
      },
    );
  }
}

class _BoardSummary extends StatelessWidget {
  const _BoardSummary({
    required this.applicationId,
    required this.completedCount,
    required this.totalCount,
    required this.progress,
  });

  final String applicationId;
  final int completedCount;
  final int totalCount;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF0B2A4A), Color(0xFF144C8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              applicationId,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '$completedCount / $totalCount modules completed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.white30,
                color: const Color(0xFFFFD54F),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleBoardTile extends StatelessWidget {
  const _ModuleBoardTile({required this.data, required this.onTap});

  final _ModuleViewData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final _TileStyle style = _TileStyle.fromState(data.state);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: style.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: style.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      data.config.code,
                      style: TextStyle(
                        color: style.foreground,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (data.state.locked)
                    Icon(Icons.lock_rounded, size: 18, color: style.foreground),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                data.config.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  _Badge(
                    label: data.state.status,
                    background: style.accent,
                    text: style.foreground,
                  ),
                  if (data.state.mandatory)
                    const _Badge(
                      label: 'Mandatory',
                      background: Color(0xFFFFF1F3),
                      text: Color(0xFFB42318),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.text,
  });

  final String label;
  final Color background;
  final Color text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ModuleViewData {
  const _ModuleViewData({required this.config, required this.state});

  final ModuleTileConfig config;
  final _ModuleState state;
}

class _ModuleState {
  const _ModuleState({
    required this.status,
    required this.mandatory,
    required this.locked,
    required this.visible,
  });

  final String status;
  final bool mandatory;
  final bool locked;
  final bool visible;
}

class _TileStyle {
  const _TileStyle({
    required this.border,
    required this.accent,
    required this.foreground,
  });

  final Color border;
  final Color accent;
  final Color foreground;

  static _TileStyle fromState(_ModuleState state) {
    if (state.status == 'COMPLETED') {
      return const _TileStyle(
        border: Color(0xFF86E0A3),
        accent: Color(0xFFEAFBF1),
        foreground: Color(0xFF027A48),
      );
    }
    if (state.status == 'IN_PROGRESS') {
      return const _TileStyle(
        border: Color(0xFFFEC84B),
        accent: Color(0xFFFFFAEB),
        foreground: Color(0xFFB54708),
      );
    }
    if (state.locked) {
      return const _TileStyle(
        border: Color(0xFFCBD5E1),
        accent: Color(0xFFF1F5F9),
        foreground: Color(0xFF475569),
      );
    }
    return const _TileStyle(
      border: Color(0xFFBFDBFE),
      accent: Color(0xFFEFF6FF),
      foreground: Color(0xFF1D4ED8),
    );
  }
}
