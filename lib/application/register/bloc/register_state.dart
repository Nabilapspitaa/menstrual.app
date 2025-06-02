// lib/application/register/bloc/register_state.dart

part of 'register_bloc.dart';

enum RegisterStatus { initial, loading, success, failure }

@immutable
class RegisterState extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final RegisterStatus status;
  final String? errorMessage;

  const RegisterState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = RegisterStatus.initial,
    this.errorMessage,
  });

  RegisterState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    RegisterStatus? status,
    String? errorMessage,
  }) {
    return RegisterState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, confirmPassword, status, errorMessage];
}