import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/register/bloc/register_bloc.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state.status == RegisterStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
            );
          // Mungkin ingin kembali ke layar login secara otomatis setelah register berhasil
          // Navigator.of(context).pop();
        } else if (state.status == RegisterStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Registrasi Gagal')),
            );
        }
      },
      child: Column(
        children: [
          _EmailInput(emailController: _emailController),
          const SizedBox(height: 15),
          _PasswordInput(passwordController: _passwordController),
          const SizedBox(height: 15),
          _ConfirmPasswordInput(
            confirmPasswordController: _confirmPasswordController,
            passwordController: _passwordController,
          ),
          const SizedBox(height: 25),
          _RegisterButton(),
        ],
      ),
    );
  }
}

class _EmailInput extends StatelessWidget {
  final TextEditingController emailController;
  const _EmailInput({required this.emailController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: state.email.isEmpty || !state.email.contains('@')
                ? 'Email tidak valid.'
                : null,
          ),
          onChanged: (email) => context.read<RegisterBloc>().add(RegisterEmailChanged(email)),
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final TextEditingController passwordController;
  const _PasswordInput({required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Kata Sandi',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: state.password.isEmpty
                ? 'Kata sandi tidak boleh kosong.'
                : (state.password.length < 6 ? 'Kata sandi minimal 6 karakter.' : null),
          ),
          onChanged: (password) => context.read<RegisterBloc>().add(RegisterPasswordChanged(password)),
        );
      },
    );
  }
}

class _ConfirmPasswordInput extends StatelessWidget {
  final TextEditingController confirmPasswordController;
  final TextEditingController passwordController;
  const _ConfirmPasswordInput({required this.confirmPasswordController, required this.passwordController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Konfirmasi Kata Sandi',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            errorText: state.confirmPassword.isEmpty
                ? 'Konfirmasi kata sandi tidak boleh kosong.'
                : (state.password != state.confirmPassword
                    ? 'Kata sandi tidak cocok.'
                    : null),
          ),
          onChanged: (confirmPassword) =>
              context.read<RegisterBloc>().add(RegisterConfirmPasswordChanged(confirmPassword)),
        );
      },
    );
  }
}

class _RegisterButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.status != current.status || previous.email != current.email || previous.password != current.password || previous.confirmPassword != current.confirmPassword,
      builder: (context, state) {
        final bool isValid = state.email.isNotEmpty && state.email.contains('@') &&
                             state.password.isNotEmpty && state.password.length >= 6 &&
                             state.confirmPassword.isNotEmpty &&
                             state.password == state.confirmPassword;
        return state.status == RegisterStatus.loading
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isValid ? () => context.read<RegisterBloc>().add(const RegisterSubmitted()) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Daftar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              );
      },
    );
  }
}