import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'features/application/presentation/cubit/application_cubit.dart';
import 'features/application/presentation/pages/application_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const LoanOriginationApp());
}

class LoanOriginationApp extends StatelessWidget {
  const LoanOriginationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loan Origination POC',
      theme: ThemeData(useMaterial3: true),
      home: BlocProvider<ApplicationCubit>(
        create: (_) => sl<ApplicationCubit>(),
        child: const ApplicationPage(),
      ),
    );
  }
}
