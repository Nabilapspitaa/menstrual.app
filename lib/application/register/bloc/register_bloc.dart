// lib/application/register/bloc/register_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_application_1/services/local_storage_service.dart';
import 'package:flutter_application_1/services/auth_api_service.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final LocalStorageService localStorageService;
  final AuthApiService authApiService;

  RegisterBloc({
    required this.localStorageService,
    required this.authApiService,
  }) : super(const RegisterState()) {
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegisterSubmitted>(_onSubmitted);
  }

  void _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(email: event.email, status: RegisterStatus.initial, errorMessage: null));
  }

  void _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(password: event.password, status: RegisterStatus.initial, errorMessage: null));
  }

  void _onConfirmPasswordChanged(
    RegisterConfirmPasswordChanged event,
    Emitter<RegisterState> emit,
  ) {
    emit(state.copyWith(confirmPassword: event.confirmPassword, status: RegisterStatus.initial, errorMessage: null));
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    if (state.password != state.confirmPassword) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: 'Kata sandi dan konfirmasi tidak cocok.'));
      return;
    }
    if (state.email.isEmpty || state.password.isEmpty || state.confirmPassword.isEmpty) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: 'Semua field harus diisi.'));
      return;
    }
    if (state.password.length < 6) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: 'Kata sandi minimal 6 karakter.'));
      return;
    }
    if (!isValidEmail(state.email)) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: 'Format email tidak valid.'));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));
    try {
      final Map<String, dynamic> responseData = await authApiService.register(
        'User Baru', // <<--- Ingat untuk mengganti ini jika Anda punya input nama di UI
        state.email,
        state.password,
      );

      emit(state.copyWith(status: RegisterStatus.success, errorMessage: responseData['message']));
    } catch (e) {
      emit(state.copyWith(status: RegisterStatus.failure, errorMessage: e.toString()));
    }
  }

  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}