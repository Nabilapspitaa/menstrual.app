// lib/application/login/bloc/login_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_application_1/services/local_storage_service.dart';
import 'package:flutter_application_1/services/auth_api_service.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LocalStorageService localStorageService;
  final AuthApiService authApiService;

  LoginBloc({
    required this.localStorageService,
    required this.authApiService,
  }) : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    LoginEmailChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: LoginStatus.initial, errorMessage: null));
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(password: event.password, status: LoginStatus.initial, errorMessage: null));
  }

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Email dan kata sandi tidak boleh kosong.'));
      return;
    }
    if (!isValidEmail(state.email)) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: 'Format email tidak valid.'));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));
    try {
      final Map<String, dynamic> responseData = await authApiService.login(state.email, state.password);

      final String token = responseData['token'];
      final Map<String, dynamic> userData = responseData['user'];

      await localStorageService.setLoggedIn(true);
      await localStorageService.saveUserEmail(userData['email'] ?? '');
      await localStorageService.saveAuthToken(token);

      emit(state.copyWith(status: LoginStatus.success, errorMessage: null));
    } catch (e) {
      emit(state.copyWith(status: LoginStatus.failure, errorMessage: e.toString()));
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}