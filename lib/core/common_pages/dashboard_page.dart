import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_strings.dart';
import '../shared_services/presentation/cubit/application_flow_cubit.dart';
import '../shared_services/presentation/cubit/application_flow_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const List<_DashboardTileData> _tiles = <_DashboardTileData>[
    _DashboardTileData(
      label: 'MY LEADS',
      routePath: '/leads',
      subtitle: 'New opportunities awaiting review',
      countLabel: 'Open Leads',
      count: 24,
      deltaText: '+6 today',
      color: Color(0xFF0052CC),
      accent: Color(0xFFE8F0FF),
      icon: Icons.person_search_rounded,
    ),
    _DashboardTileData(
      label: 'MY PROPOSALS',
      routePath: '/proposals',
      subtitle: 'Applications moving through sanction stages',
      countLabel: 'In Progress',
      count: 11,
      deltaText: '3 pending approval',
      color: Color(0xFF1B8754),
      accent: Color(0xFFE8FFF3),
      icon: Icons.description_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.dashboardTitle),
        centerTitle: false,
      ),
      floatingActionButton: BlocBuilder<ApplicationFlowCubit, ApplicationFlowState>(
        builder: (BuildContext context, ApplicationFlowState state) {
          return FloatingActionButton.extended(
            onPressed: state.status == ApplicationFlowStatus.loading
                ? null
                : () async {
                    final ApplicationFlowCubit flowCubit = context
                        .read<ApplicationFlowCubit>();
                    await flowCubit.createProposal();
                    if (!context.mounted) {
                      return;
                    }
                    final String? appId = flowCubit.state.currentApplicationId;
                    if (appId == null) {
                      return;
                    }
                    context.push('/proposal/$appId/modules');
                  },
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Application'),
          );
        },
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            sliver: SliverToBoxAdapter(
              child: _OverviewCard(
                title: 'Welcome back',
                subtitle: AppStrings.dashboardSubtitle,
                stats: const <_StatChipData>[
                  _StatChipData(label: 'Today', value: '12 Follow-ups'),
                  _StatChipData(label: 'SLA', value: '98.4% On Time'),
                  _StatChipData(label: 'Conversion', value: '41%'),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            sliver: SliverLayoutBuilder(
              builder: (BuildContext context, constraints) {
                final double width = constraints.crossAxisExtent;
                final int crossAxisCount = width > 960 ? 2 : 1;
                final double aspectRatio = width > 960 ? 2.3 : 1.7;

                return SliverGrid.builder(
                  itemCount: _tiles.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: aspectRatio,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    final _DashboardTileData tile = _tiles[index];
                    return _DashboardTile(
                      data: tile,
                      textTheme: theme.textTheme,
                      onTap: () => context.push(tile.routePath),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.title,
    required this.subtitle,
    required this.stats,
  });

  final String title;
  final String subtitle;
  final List<_StatChipData> stats;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[Color(0xFF001F3F), Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats
                  .map((_StatChipData item) => _StatChip(item: item))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.item});

  final _StatChipData item;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: RichText(
          text: TextSpan(
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: Colors.white),
            children: <TextSpan>[
              TextSpan(
                text: '${item.label}: ',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              TextSpan(text: item.value),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.data,
    required this.onTap,
    required this.textTheme,
  });

  final _DashboardTileData data;
  final VoidCallback onTap;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: data.color.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: data.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(data.icon, color: data.color),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, color: data.color),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                data.label,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${data.count}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: data.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(data.countLabel, style: textTheme.bodySmall),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: data.accent,
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                child: Text(
                  data.deltaText,
                  style: textTheme.labelSmall?.copyWith(
                    color: data.color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardTileData {
  const _DashboardTileData({
    required this.label,
    required this.routePath,
    required this.subtitle,
    required this.countLabel,
    required this.count,
    required this.deltaText,
    required this.color,
    required this.accent,
    required this.icon,
  });

  final String label;
  final String routePath;
  final String subtitle;
  final String countLabel;
  final int count;
  final String deltaText;
  final Color color;
  final Color accent;
  final IconData icon;
}

class _StatChipData {
  const _StatChipData({required this.label, required this.value});

  final String label;
  final String value;
}
