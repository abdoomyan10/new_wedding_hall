import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:new_wedding_hall/injection_container.dart' as di;
import 'package:new_wedding_hall/core/utils/request_state.dart';
import 'package:new_wedding_hall/core/constants/app_colors.dart';
import 'package:new_wedding_hall/features/auth/domain/usecase/login-user.dart';
import 'package:new_wedding_hall/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:new_wedding_hall/features/auth/presentation/bloc/auth_event.dart';
import 'package:new_wedding_hall/features/auth/presentation/bloc/auth_state.dart';
import 'package:new_wedding_hall/features/auth/presentation/pages/signupscreen.dart';
import 'package:new_wedding_hall/presentation/pages/main_page.dart';

import '../../../../core/services/dependencies.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Use central palette from AppColors
  // Colors are defined in lib/core/theme/app_colors.dart
  // (imported lazily below)

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // تنفيذ عملية تسجيل الدخول هنا
      getIt<AuthBloc>().add(
        LoginEvent(
          params: LoginParams(
            email: _emailController.text,
            password: _passwordController.text,
          ),
        ),
      );

      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paleGold.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: AppColors.deepRed,
        title: const Text('تسجيل الدخول', style: TextStyle()),
        foregroundColor: AppColors.paleGold,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/mozhela.png',
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // حقل البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(color: AppColors.deepRed),
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email, color: AppColors.deepRed),
                  // Use deep red for focused/border and gold accents
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.deepRed),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.gold, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال البريد الإلكتروني';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'بريد إلكتروني غير صالح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // حقل كلمة المرور
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  floatingLabelStyle: TextStyle(color: AppColors.deepRed),
                  labelText: 'كلمة المرور',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.deepRed,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.deepRed),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.gold, width: 2),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال كلمة المرور';
                  }
                  if (value.length < 6) {
                    return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // نسيت كلمة المرور؟
              const SizedBox(height: 30),
              // زر تسجيل الدخول
              BlocConsumer<AuthBloc, AuthState>(
                bloc: getIt<AuthBloc>(),
                listener: (context, state) {
                  if (state.status == RequestStatus.success) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return MainPage();
                        },
                      ),
                    );
                  }
                  // TODO: implement listener
                },
                builder: (context, state) {
                  return ElevatedButton.icon(
                    icon: state.status == RequestStatus.loading
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.paleGold,
                              ),
                            ),
                          )
                        : const Icon(Icons.login),
                    onPressed: state.status != RequestStatus.loading
                        ? _login
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deepRed,
                      foregroundColor: AppColors.paleGold,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    label: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              // خط فاصل
              Row(
                children: [
                  Expanded(child: Divider(color: AppColors.deepRed)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'أو',
                      style: TextStyle(color: AppColors.deepRed),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.deepRed)),
                ],
              ),
              const SizedBox(height: 20),
              // زر إنشاء حساب جديد
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.gold, width: 1.5),
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'إنشاء حساب جديد',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
