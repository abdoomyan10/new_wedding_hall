import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:new_wedding_hall/features/expenses/presentation/pages/expenses_page.dart';
import 'package:new_wedding_hall/features/payments/presentation/pages/payments_page.dart';
import 'package:new_wedding_hall/features/report/presentation/pages/reports.dart';

import '../../features/home/presentation/pages/home_page.dart';
import '../../features/payments/presentation/widgets/Add_Payment_dialog.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../bottom_nav_cubit.dart';
import '../widgets/custom_bottom_nav_bar.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BottomNavCubit(),
      child: const _MainPageContent(),
    );
  }
}

class _MainPageContent extends StatelessWidget {
  const _MainPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<BottomNavCubit, int>(
        builder: (context, currentIndex) {
          return IndexedStack(
            index: currentIndex,
            children: [
              const HomePage(),
              const ReportsPage(),
              const PaymentsPage(),
              const ExpensesPage(),
              SettingsPage(),
            ],
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavBar(),
    );
  }
}
