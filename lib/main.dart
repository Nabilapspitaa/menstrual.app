// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_application_1/services/local_storage_service.dart';
import 'package:flutter_application_1/services/auth_api_service.dart';

import 'package:flutter_application_1/view/home_page.dart';
import 'package:flutter_application_1/view/login.dart';
import 'package:flutter_application_1/view/register_page.dart'; // Pastikan nama file ini benar (e.g. register_page.dart)

import 'package:flutter_application_1/application/login/bloc/login_bloc.dart';
import 'package:flutter_application_1/application/register/bloc/register_bloc.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final LocalStorageService localStorageService = LocalStorageService();
  final AuthApiService authApiService = AuthApiService();


  final bool isLoggedInInitially = await localStorageService.isLoggedIn();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(
            localStorageService: localStorageService,
            authApiService: authApiService,
          ),
        ),
        BlocProvider<RegisterBloc>(
          create: (context) => RegisterBloc(
            localStorageService: localStorageService,
            authApiService: authApiService,
          ),
        ),
      ],
      child: MyApp(isLoggedIn: isLoggedInInitially),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = widget.isLoggedIn;
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() async {
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Period Tracker',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: _isLoggedIn ? const MyHomePage() : const LoginPage(),
      routes: {
        '/home': (context) => const MyHomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(), 
      },
    );
  }
}