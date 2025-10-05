import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/payments/presentation/cubit/payment_cubit.dart';
import 'features/expenses/presentation/cubit/expense_cubit.dart'; // ✅ إضافة ExpenseCubit
import 'injection_container.dart' as di;
import 'firebase_options.dart';
import 'presentation/pages/main_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔥 تهيئة Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 🧠 تهيئة dependency injection
    await di.init();

    // 🚀 تشغيل التطبيق
    runApp(const MainApp());
  } catch (e) {
    print('Error in main: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => di.sl<HomeCubit>()..loadHomeData(),
        ),
        BlocProvider<PaymentCubit>(
          create: (context) => di.sl<PaymentCubit>()..loadPayments(),
        ),
        BlocProvider<ExpenseCubit>( // ✅ إضافة ExpenseCubit
          create: (context) => di.sl<ExpenseCubit>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const MainPage(),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}