// features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/dependencies.dart';
import '../../../../injection_container.dart';
import '../cubit/home_cubit.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/home_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeCubit>()..loadHomeData(),
      child: Scaffold(appBar: const HomeAppBar(), body: const _HomeBody()),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeLoaded) {
          return const HomeContent();
        } else if (state is HomeError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('مرحباً بك في تطبيق محاسبة الأفراح'));
      },
    );
  }
}
