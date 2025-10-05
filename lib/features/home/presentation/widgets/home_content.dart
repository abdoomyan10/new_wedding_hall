// features/home/presentation/widgets/home_content.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/home_entity.dart';
import '../cubit/home_cubit.dart';

import 'welcome_card.dart';
import 'quick_stats_card.dart';
import 'quick_actions_grid.dart';
import 'upcoming_events_section.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoaded) {
          final homeData = state.homeData;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بطاقة الترحيب
                WelcomeCard(userName: homeData.userName),
                const SizedBox(height: 20),

                // الإحصائيات السريعة
                QuickStatsCard(homeData: homeData),
                const SizedBox(height: 20),

                // الإجراءات السريعة
                const QuickActionsGrid(),
                const SizedBox(height: 20),

                // الحفلات القادمة
                const UpcomingEventsSection(),
              ],
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}