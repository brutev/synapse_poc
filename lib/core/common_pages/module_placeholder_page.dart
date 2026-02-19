import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

class ModulePlaceholderPage extends StatelessWidget {
  const ModulePlaceholderPage({
    required this.moduleId,
    required this.applicationId,
    super.key,
  });

  final String moduleId;
  final String applicationId;

  @override
  Widget build(BuildContext context) {
    final ModuleTileConfig? module = _findModule(moduleId);

    return Scaffold(
      appBar: AppBar(title: Text(module?.title ?? moduleId)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            module == null
                ? 'Unknown module'
                : 'Application: $applicationId\n\nModule ${module.code}: ${module.title}\nScreen scaffold is ready.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  ModuleTileConfig? _findModule(String id) {
    for (final ModuleTileConfig module in loanModules) {
      if (module.sectionId == id) {
        return module;
      }
    }
    return null;
  }
}
