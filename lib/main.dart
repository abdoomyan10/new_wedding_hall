import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/services/dependencies.dart';
import 'core/utils/font_loader.dart'; // إضافة الاستيراد
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/payments/domain/repositories/payment_repository.dart';
import 'features/payments/domain/usecases/Update_Payment_UseCase.dart';
import 'features/payments/presentation/cubit/payment_cubit.dart';
import 'features/expenses/presentation/cubit/expense_cubit.dart';
import 'injection_container.dart' as di;
import 'firebase_options.dart';
// main_page.dart is not referenced here because app starts at splash screen
import 'features/auth/presentation/pages/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('🧠 Initializing DI...');
    await di.init();
    configureDependencies();
    print('✅ DI initialized');

    // ✅ تهيئة الخطوط العربية قبل تشغيل التطبيق
    print('🔄 تحميل الخطوط العربية...');
    await FontLoader.loadFont();
    print('✅ الخطوط العربية جاهزة: ${FontLoader.currentFont}');
    print('📝 معلومات الخطوط: ${FontLoader.fontInfo}');

    testDependencies();

    runApp(const MainApp());
  } catch (e) {
    print('❌ Error in main: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

void testDependencies() {
  print('🔍 Testing dependencies...');

  final tests = [
    {
      'name': 'UpdatePaymentUseCase',
      'test': () => getIt<UpdatePaymentUseCase>(),
    },
    {'name': 'PaymentRepository', 'test': () => getIt<PaymentRepository>()},
    {'name': 'PaymentCubit', 'test': () => getIt<PaymentCubit>()},
  ];

  for (var test in tests) {
    try {
      // actually invoke the closure to retrieve the dependency
      (test['test'] as dynamic)();
      print('✅ ${test['name']} - SUCCESS');
    } catch (e) {
      print('❌ ${test['name']} - FAILED: $e');
    }
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(
          create: (context) => getIt<HomeCubit>()..loadHomeData(),
        ),
        BlocProvider<PaymentCubit>(
          create: (context) => getIt<PaymentCubit>()..loadPayments(),
        ),
        BlocProvider<ExpenseCubit>(create: (context) => getIt<ExpenseCubit>()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'Tajawal', // تعيين الخط الافتراضي للتطبيق
        ),
        home: const SplashScreen(),
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'حدث خطأ في التطبيق',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => main(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}