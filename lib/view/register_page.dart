// lib/view/register_page.dart (Contoh Struktur)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_application_1/application/register/bloc/register_bloc.dart';

class RegisterPage extends StatelessWidget { // <<--- Pastikan nama kelasnya 'RegisterPage'
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocConsumer<RegisterBloc, RegisterState>(
          listener: (context, state) {
            if (state.status == RegisterStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Registrasi berhasil!')),
              );
              // Mungkin arahkan ke halaman login setelah registrasi berhasil
              Navigator.pushReplacementNamed(context, '/login');
            } else if (state.status == RegisterStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage ?? 'Registrasi gagal.')),
              );
            }
          },
          builder: (context, state) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  onChanged: (email) => context.read<RegisterBloc>().add(RegisterEmailChanged(email)),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  onChanged: (password) => context.read<RegisterBloc>().add(RegisterPasswordChanged(password)),
                  decoration: const InputDecoration(
                    labelText: 'Kata Sandi',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16.0),
                TextField(
                  onChanged: (confirmPassword) => context.read<RegisterBloc>().add(RegisterConfirmPasswordChanged(confirmPassword)),
                  decoration: const InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24.0),
                state.status == RegisterStatus.loading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () {
                          context.read<RegisterBloc>().add(const RegisterSubmitted());
                        },
                        child: const Text('Daftar'),
                      ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Kembali ke halaman login
                  },
                  child: const Text('Sudah punya akun? Masuk di sini.'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}