// lib/view/journal_home_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:uuid/uuid.dart'; // Untuk ID unik
import 'package:line_icons/line_icons.dart'; // Import LineIcons untuk ikon yang lebih variatif

import 'package:flutter_application_1/widget/navigation.dart'; // Pastikan path ini benar
import 'package:flutter_application_1/models/journal_entry.dart'; // Pastikan path ini benar
import 'package:flutter_application_1/services/local_storage_service.dart'; // Pastikan path ini benar

class JournalHomePage extends StatefulWidget {
  const JournalHomePage({super.key});

  @override
  State<JournalHomePage> createState() => _JournalHomePageState();
}

class _JournalHomePageState extends State<JournalHomePage> {
  final LocalStorageService _localStorageService = LocalStorageService();
  List<JournalEntry> _journalEntries = [];

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  Future<void> _loadJournalEntries() async {
    _journalEntries = await _localStorageService.getJournalEntries();
    // Urutkan berdasarkan tanggal terbaru ke terlama
    _journalEntries.sort((a, b) => b.date.compareTo(a.date));
    setState(() {}); // Perbarui UI setelah data dimuat
  }

  Future<void> _addJournalEntry(String content) async {
    final newEntry = JournalEntry(
      id: const Uuid().v4(), // Generate ID unik baru
      content: content,
      date: DateTime.now(), // Tanggal otomatis saat ini
    );
    setState(() {
      _journalEntries.add(newEntry);
      _journalEntries.sort((a, b) => b.date.compareTo(a.date)); // Urutkan lagi
    });
    await _localStorageService.saveJournalEntries(_journalEntries);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan berhasil disimpan!')),
      );
    }
  }

  Future<void> _editJournalEntry(JournalEntry entryToEdit) async {
    final TextEditingController editController = TextEditingController(text: entryToEdit.content);
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Catatan Jurnal'),
          content: TextField(
            controller: editController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Edit catatanmu...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final updatedContent = editController.text.trim();
      if (updatedContent.isNotEmpty) {
        setState(() {
          final index = _journalEntries.indexWhere((entry) => entry.id == entryToEdit.id);
          if (index != -1) {
            _journalEntries[index] = entryToEdit.copyWith(content: updatedContent);
            _journalEntries.sort((a, b) => b.date.compareTo(a.date)); // Urutkan lagi
          }
        });
        await _localStorageService.saveJournalEntries(_journalEntries);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan berhasil diperbarui!')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Catatan tidak boleh kosong.')),
          );
        }
      }
    }
  }

  Future<void> _deleteJournalEntry(String id) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            ElevatedButton(
              child: const Text('Hapus'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() {
        _journalEntries.removeWhere((entry) => entry.id == id);
      });
      await _localStorageService.saveJournalEntries(_journalEntries);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dihapus!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal Harian'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selamat Datang di Jurnalmu!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () async {
                final newEntryContent = await Navigator.push<String?>(
                  context,
                  MaterialPageRoute(builder: (context) => const NewJournalEntryScreen()),
                );
                if (newEntryContent != null && newEntryContent.isNotEmpty) {
                  await _addJournalEntry(newEntryContent);
                }
              },
              // Memindahkan label di atas icon untuk mengikuti aturan linting
              label: const Text('Buat Catatan Baru'),
              icon: const Icon(Icons.add),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Catatan Terbaru:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _journalEntries.isEmpty
                ? Center( // Menggunakan Center untuk ikon dan teks
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        // Ikon yang lebih menarik saat jurnal kosong
                        Icon(LineIcons.bookOpen, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum ada catatan jurnal.\nYuk, buat catatan pertamamu!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _journalEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _journalEntries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.content,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                DateFormat('dd MMMM yyyy, HH:mm').format(entry.date), // PERBAIKAN FORMAT TANGGAL di sini
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _editJournalEntry(entry),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteJournalEntry(entry.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 2),
    );
  }
}

// ====================================================================
// NewJournalEntryScreen.dart (Diletakkan di file yang sama atau file terpisah)
// ====================================================================
class NewJournalEntryScreen extends StatefulWidget {
  const NewJournalEntryScreen({super.key});

  @override
  State<NewJournalEntryScreen> createState() => _NewJournalEntryScreenState();
}

class _NewJournalEntryScreenState extends State<NewJournalEntryScreen> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Baru'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        leading: IconButton( // Tombol back
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column( // Menggunakan Column agar bisa menaruh TextField dan ElevatedButton
          children: [
            Expanded( // TextField mengambil sisa ruang yang tersedia
              child: TextField(
                controller: _textController,
                maxLines: null, // Memungkinkan TextField untuk mengambil sebanyak mungkin baris
                expands: true, // Membuat TextField mengambil seluruh ruang yang tersedia di Expanded
                decoration: const InputDecoration(
                  hintText: 'Tuliskan catatanmu di sini...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(height: 16), // Jarak antara TextField dan tombol
            SizedBox( // Menggunakan SizedBox untuk mengatur lebar tombol
              width: double.infinity, // Membuat tombol mengisi seluruh lebar
              child: ElevatedButton.icon(
                onPressed: () {
                  String newEntry = _textController.text.trim();
                  if (newEntry.isNotEmpty) {
                    Navigator.pop(context, newEntry);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Catatan tidak boleh kosong.')),
                    );
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text('Simpan Catatan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink, // Warna tombol
                  foregroundColor: Colors.white, // Warna teks dan ikon
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}