import 'package:flutter/material.dart';

class LeadsPage extends StatelessWidget {
  const LeadsPage({super.key});

  static const List<_LeadItem> _leads = <_LeadItem>[
    _LeadItem(name: 'Arjun Logistics', location: 'Coimbatore', priority: 'Hot'),
    _LeadItem(name: 'Maha Transports', location: 'Madurai', priority: 'Warm'),
    _LeadItem(name: 'KVR Fleet', location: 'Salem', priority: 'Cold'),
    _LeadItem(name: 'Sai Goods Carrier', location: 'Erode', priority: 'Warm'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Leads')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              decoration: InputDecoration(
                hintText: 'Search leads',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: _leads.length,
                separatorBuilder: (BuildContext context, int index) =>
                    const SizedBox(height: 10),
                itemBuilder: (BuildContext context, int index) {
                  final _LeadItem item = _leads[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(item.name.substring(0, 1)),
                      ),
                      title: Text(item.name),
                      subtitle: Text(item.location),
                      trailing: _PriorityChip(priority: item.priority),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (priority) {
      'Hot' => const Color(0xFFB42318),
      'Warm' => const Color(0xFFB54708),
      _ => const Color(0xFF344054),
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          priority,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _LeadItem {
  const _LeadItem({
    required this.name,
    required this.location,
    required this.priority,
  });

  final String name;
  final String location;
  final String priority;
}
