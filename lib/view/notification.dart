// lib/view/notification_page.dart

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart'; // Import LineIcons untuk ikon yang lebih menarik

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // Latar belakang halaman yang konsisten
      appBar: AppBar(
        title: const Text(
          'Notifikasi Anda', // Judul yang lebih deskriptif
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Teks judul putih dan tebal
        ),
        backgroundColor: Colors.pink, // Warna AppBar jadi pink
        foregroundColor: Colors.white, // Warna ikon dan teks di AppBar jadi putih
        centerTitle: true, // Judul di tengah
        elevation: 0, // Hapus bayangan AppBar
      ),
      body: Center( // Menggunakan Center untuk memusatkan konten saat tidak ada notifikasi
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Padding di sekitar konten
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon notifikasi yang lebih menarik
              Icon(
                LineIcons.bellSlash, // Ikon bel dengan garis miring (tidak ada notifikasi)
                size: 100, // Ukuran ikon lebih besar
                color: Colors.grey[400], // Warna abu-abu muda
              ),
              const SizedBox(height: 20),
              const Text(
                'Belum ada notifikasi baru saat ini.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'Notifikasi penting terkait siklus menstruasi Anda dan pengingat akan muncul di sini.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40), // Spasi di bagian bawah
            ],
          ),
        ),
      ),
    );
  }
}