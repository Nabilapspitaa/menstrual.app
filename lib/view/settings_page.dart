// lib/view/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/widget/navigation.dart'; // Untuk bottom navigation bar
import 'package:flutter_application_1/services/local_storage_service.dart'; // Untuk logout
import 'package:flutter_application_1/view/login.dart'; // Pastikan path ini benar untuk LoginPage
import 'package:shared_preferences/shared_preferences.dart'; // Untuk mengambil nama pengguna

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _userName = 'Pengguna'; // Nama pengguna default

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Pengguna'; // Asumsi 'userName' disimpan di SharedPreferences
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Selamat Pagi';
    } else if (hour >= 12 && hour < 18) {
      return 'Selamat Siang';
    } else if (hour >= 18 && hour < 22) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // Latar belakang pink muda
      appBar: AppBar(
        backgroundColor: Colors.pink[50], // Sesuaikan dengan latar belakang body
        elevation: 0, // Tanpa bayangan
        toolbarHeight: 0, // Sembunyikan app bar bawaan untuk custom header
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom Header Section (mirip Home Page)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()},',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text(
                        _userName,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink[700]),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.black54, size: 28),
                        onPressed: () {
                          // Aksi untuk notifikasi
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Halaman Notifikasi')),
                          );
                          // Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationPage()));
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.black54, size: 26), // Menggunakan ikon settings di sini
                        onPressed: () {
                          // Aksi untuk pengaturan, mungkin refresh halaman atau info
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Banner Info di Settings (opsional, bisa disesuaikan)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kelola pengaturan aplikasimu!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.pink[800],
                    ),
                  ),
                  Icon(Icons.tune, color: Colors.pink[700], size: 30), // Ikon Pengaturan
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Opsi Pengaturan dalam bentuk Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Kategori Akun
                  _buildSettingsCategoryTitle('Akun'),
                  _buildSettingsOptionCard(
                    context,
                    icon: Icons.person_outline,
                    title: 'Edit Profil',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigasi ke Halaman Edit Profil')),
                      );
                    },
                  ),
                  _buildSettingsOptionCard(
                    context,
                    icon: Icons.lock_outline,
                    title: 'Ganti Kata Sandi',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigasi ke Halaman Ganti Kata Sandi')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Kategori Preferensi
                  _buildSettingsCategoryTitle('Preferensi'),
                  _buildSettingsOptionCard(
                    context,
                    icon: Icons.notifications_none,
                    title: 'Pengaturan Notifikasi',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigasi ke Halaman Pengaturan Notifikasi')),
                      );
                    },
                  ),
                  _buildSettingsOptionCard(
                    context,
                    icon: Icons.color_lens_outlined,
                    title: 'Tema Aplikasi',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigasi ke Halaman Tema Aplikasi')),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Kategori Informasi & Dukungan
                  _buildSettingsCategoryTitle('Informasi & Dukungan'),
                  _buildSettingsOptionCard(
                    context,
                    icon: Icons.help_outline,
                    title: 'Bantuan & FAQ',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigasi ke Halaman Bantuan & FAQ')),
                      );
                    },
                  ),
                  _buildSettingsOptionCard(
                    context,
                    icon: Icons.info_outline,
                    title: 'Tentang Aplikasi',
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'Health Tracker App',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2024 Nabila, All rights reserved.',
                        children: <Widget>[
                          const Padding(
                            padding: EdgeInsets.only(top: 15.0),
                            child: Text('Aplikasi ini membantu Anda memantau siklus menstruasi, jurnal, dan kesehatan secara keseluruhan.'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Logout
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  final bool? confirmLogout = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Konfirmasi Logout'),
                        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Batal', style: TextStyle(color: Colors.pink)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                          ),
                          ElevatedButton(
                            child: const Text('Logout', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirmLogout == true) {
                    await LocalStorageService().setLoggedIn(false);
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 3), // Sesuaikan index Settings
    );
  }

  // Widget pembantu untuk judul kategori pengaturan
  Widget _buildSettingsCategoryTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.pink[700],
        ),
      ),
    );
  }

  // Widget pembantu untuk setiap opsi pengaturan dalam bentuk Card yang bisa diklik
  Widget _buildSettingsOptionCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Sudut lebih bulat seperti card di Home
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0), // Padding yang lebih konsisten
          child: Row(
            children: [
              Icon(icon, color: Colors.pink, size: 30), // Ikon lebih besar dan warna pink
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 17, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}