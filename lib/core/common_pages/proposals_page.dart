import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../shared_services/presentation/cubit/application_flow_cubit.dart';
import '../shared_services/presentation/cubit/application_flow_state.dart';

class ProposalsPage extends StatelessWidget {
  const ProposalsPage({super.key});

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
        final List<ProposalSummary> proposals = state.proposals;

        return Scaffold(
          appBar: AppBar(title: const Text('My Proposals')),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.status == ApplicationFlowStatus.loading
                ? null
                : () => context.read<ApplicationFlowCubit>().createProposal(),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Create Proposal'),
          ),
          body: switch (state.status) {
            ApplicationFlowStatus.loading => const Center(
              child: CircularProgressIndicator(),
            ),
            _ =>
              proposals.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: proposals.length,
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (BuildContext context, int index) {
                        final ProposalSummary item = proposals[index];
                        return _ProposalCard(
                          item: item,
                          onTap: () => context.push(
                            '/proposal/${item.applicationId}/modules',
                          ),
                        );
                      },
                    ),
          },
        );
      },
    );
  }
}

class _ProposalCard extends StatelessWidget {
  const _ProposalCard({required this.item, required this.onTap});

  final ProposalSummary item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      item.applicationId,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _PhaseTag(phase: item.phase),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: item.progress,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
              ),
              const SizedBox(height: 8),
              Text('${(item.progress * 100).round()}% modules completed'),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhaseTag extends StatelessWidget {
  const _PhaseTag({required this.phase});

  final String phase;

  @override
  Widget build(BuildContext context) {
    final bool isPre = phase == 'PRE_SANCTION';
    final Color color = isPre
        ? const Color(0xFF175CD3)
        : const Color(0xFF027A48);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          phase,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const <Widget>[
            Icon(Icons.description_outlined, size: 48),
            SizedBox(height: 12),
            Text('No proposals yet. Create one to start evaluation.'),
          ],
        ),
      ),
    );
  }
}
