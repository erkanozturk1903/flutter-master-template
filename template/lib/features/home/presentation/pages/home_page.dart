import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../widgets/home_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<HomeBloc>()..add(const LoadWelcomeMessage()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Master Template'),
          actions: [
            BlocBuilder<HomeBloc, dynamic>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => context
                      .read<HomeBloc>()
                      .add(const RefreshWelcomeMessage()),
                );
              },
            ),
          ],
        ),
        body: const HomeContent(),
      ),
    );
  }
}
