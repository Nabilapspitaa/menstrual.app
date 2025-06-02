// lib/view/login.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/application/login/bloc/login_bloc.dart'; // Pastikan path ini benar

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masuk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // BlocConsumer akan secara otomatis menemukan LoginBloc yang sudah disediakan oleh main.dart
        child: BlocConsumer<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state.status == LoginStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Login berhasil!')),
              );
              // Arahkan ke halaman utama setelah login berhasil
              Navigator.pushReplacementNamed(context, '/home');
            } else if (state.status == LoginStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Login gagal.')),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  // Menggunakan context.read untuk mengakses instance LoginBloc yang sudah ada
                  onChanged: (email) => context.read<LoginBloc>().add(LoginEmailChanged(email)),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  // Menggunakan context.read untuk mengakses instance LoginBloc yang sudah ada
                  onChanged: (password) => context.read<LoginBloc>().add(LoginPasswordChanged(password)),
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24.0),
                state.status == LoginStatus.loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          // Menggunakan context.read untuk mengakses instance LoginBloc yang sudah ada
                          context.read<LoginBloc>().add(const LoginSubmitted());
                        },
                        child: const Text('Masuk'),
                      ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    // Arahkan ke halaman register
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Belum punya akun? Daftar di sini.'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}