import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:new_wedding_hall/injection_container.dart' as di;
import 'package:new_wedding_hall/core/utils/request_state.dart';
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
      appBar: AppBar(title: const Text('تسجيل الدخول'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              // شعار التطبيق (اختياري)
              Image.asset('assets/logo.jpg', height: 120, width: 120),
              const SizedBox(height: 40),
              // حقل البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email),
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
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
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
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    // إضافة صفحة استعادة كلمة المرور لاحقًا
                  },
                  child: const Text('نسيت كلمة المرور؟'),
                ),
              ),
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
                        ? CircularProgressIndicator()
                        : null,
                    onPressed: state.status != RequestStatus.loading
                        ? _login
                        : null,
                    label: Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
                  );
                },
              ),
              const SizedBox(height: 20),
              // خط فاصل
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('أو'),
                  ),
                  Expanded(child: Divider()),
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
