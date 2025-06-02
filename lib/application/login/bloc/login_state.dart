part of 'login_bloc.dart';

enum LoginStatus { initial, loading, success, failure }

@immutable
class LoginState extends Equatable {
  const LoginState({
    this.email = '', // String biasa
    this.password = '', // String biasa
    this.status = LoginStatus.initial,
    this.errorMessage,
  });

  final String email; // String biasa
  final String password; // String biasa
  final LoginStatus status;
  final String? errorMessage;

  LoginState copyWith({
    String? email, // String biasa
    String? password, // String biasa
    LoginStatus? status,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [email, password, status, errorMessage];
}