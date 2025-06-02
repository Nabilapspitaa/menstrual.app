import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../application/login/bloc/login_bloc.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          // Navigasi tidak perlu di sini jika StreamBuilder di main.dart sudah menangani
          // Tapi ScaffoldMessenger untuk pesan sukses tetap bisa
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Login berhasil!')),
            );
        } else if (state.status == LoginStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Login Gagal')),
            );
        }
      },
      child: Column(
        children: [
          _EmailInput(emailController: _emailController),
          const SizedBox(height: 15),
          _PasswordInput(passwordController: _passwordController),
          const SizedBox(height: 25),
          _LoginButton(),
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
    return BlocBuilder<LoginBloc, LoginState>(
      // buildWhen tidak perlu jika email adalah String biasa
      builder: (context, state) {
        return TextFormField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            // Validasi di sini jika tidak pakai FormzInput
            errorText: state.email.isEmpty ? 'Email tidak boleh kosong.' : null,
          ),
          onChanged: (email) => context.read<LoginBloc>().add(LoginEmailChanged(email)),
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
    return BlocBuilder<LoginBloc, LoginState>(
      // buildWhen tidak perlu jika password adalah String biasa
      builder: (context, state) {
        return TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Kata Sandi',
            prefixIcon: const Icon(Icons.lock),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            // Validasi di sini jika tidak pakai FormzInput
            errorText: state.password.isEmpty
                ? 'Kata sandi tidak boleh kosong.'
                : (state.password.length < 6 ? 'Kata sandi minimal 6 karakter.' : null),
          ),
          onChanged: (password) => context.read<LoginBloc>().add(LoginPasswordChanged(password)),
        );
      },
    );
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginBloc, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status || previous.email != current.email || previous.password != current.password,
      builder: (context, state) {
        final bool isValid = state.email.isNotEmpty && state.password.isNotEmpty && state.password.length >= 6;
        return state.status == LoginStatus.loading
            ? const CircularProgressIndicator()
            : SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isValid ? () => context.read<LoginBloc>().add(const LoginSubmitted()) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              );
      },
    );
  }
}