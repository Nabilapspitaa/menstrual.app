// lib/view/history_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/menstrual_data.dart';
import 'package:flutter_application_1/services/local_storage_service.dart';
import 'package:flutter_application_1/widget/navigation.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final LocalStorageService _localStorageService = LocalStorageService();
  List<MenstrualData> _menstrualHistory = [];

  // Konstanta untuk durasi siklus
  final int _averageCycleLength = 28; // Durasi siklus rata-rata
  final int _normalCycleMin = 21;    // Minimal durasi siklus normal
  final int _normalCycleMax = 35;    // Maksimal durasi siklus normal
  final int _lutealPhase = 14;       // Fase luteal (setelah ovulasi sampai menstruasi)

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    _menstrualHistory = await _localStorageService.getMenstrualData();
    _menstrualHistory.sort((a, b) => b.startDate.compareTo(a.startDate)); // Sort from newest to oldest
    setState(() {});
  }

  // U: Update (Edit)
  Future<void> _editEntry(int index) async {
    MenstrualData currentData = _menstrualHistory[index];
    DateTime tempStartDate = currentData.startDate;
    DateTime tempEndDate = currentData.endDate;
    List<String> tempSymptoms = List.from(currentData.symptoms); // Create a mutable copy

    // Gejala dalam Bahasa Indonesia, diselaraskan dengan input Anda
    final List<String> allSymptoms = ['Kram', 'Sakit Kepala', 'Kembung', 'Lelah', 'Mood Swing', 'Jerawat'];

    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Catatan Menstruasi'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text("Tanggal Mulai: ${DateFormat('dd MMMM yyyy').format(tempStartDate)}"), // FIX: yyyy for year
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: tempStartDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != tempStartDate) {
                          setState(() {
                            tempStartDate = picked;
                            if (tempEndDate.isBefore(tempStartDate)) {
                              tempEndDate = tempStartDate; // Adjust end date if it's before new start date
                            }
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text("Tanggal Selesai: ${DateFormat('dd MMMM yyyy').format(tempEndDate)}"), // FIX: yyyy for year
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: tempEndDate,
                          firstDate: tempStartDate, // End date cannot be before start date
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != tempEndDate) {
                          setState(() {
                            tempEndDate = picked;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    const Text('Pilih Gejala:'),
                    Wrap(
                      spacing: 8.0,
                      children: allSymptoms.map((symptom) {
                        return FilterChip(
                          label: Text(symptom),
                          selected: tempSymptoms.contains(symptom),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                tempSymptoms.add(symptom);
                              } else {
                                tempSymptoms.remove(symptom);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Simpan'),
              onPressed: () {
                if (tempEndDate.isBefore(tempStartDate)) {
                   ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Tanggal selesai tidak boleh sebelum tanggal mulai!')),
                  );
                  return;
                }
                setState(() {
                  _menstrualHistory[index] = MenstrualData(
                    startDate: tempStartDate,
                    endDate: tempEndDate,
                    symptoms: tempSymptoms,
                  );
                  _menstrualHistory.sort((a, b) => b.startDate.compareTo(a.startDate)); // Re-sort after edit
                });
                _localStorageService.saveMenstrualData(_menstrualHistory);
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catatan berhasil diperbarui!')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  // D: Delete
  Future<void> _deleteEntry(int index) async {
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
        _menstrualHistory.removeAt(index);
      });
      await _localStorageService.saveMenstrualData(_menstrualHistory);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil dihapus!')),
        );
      }
    }
  }

  // Fungsi untuk mendapatkan status siklus
  String _getCycleStatus() {
    if (_menstrualHistory.length < 2) {
      return "Belum ada data cukup untuk perkiraan siklus.";
    }

    // Ambil dua siklus terakhir untuk menghitung durasi
    DateTime lastPeriodStart = _menstrualHistory[0].startDate;
    DateTime secondLastPeriodStart = _menstrualHistory[1].startDate;

    int cycleDuration = lastPeriodStart.difference(secondLastPeriodStart).inDays;

    if (cycleDuration >= _normalCycleMin && cycleDuration <= _normalCycleMax) {
      return "Siklus Anda (${cycleDuration} hari) cenderung normal.";
    } else if (cycleDuration < _normalCycleMin) {
      return "Siklus Anda (${cycleDuration} hari) cenderung pendek/tidak teratur.";
    } else { // cycleDuration > _normalCycleMax
      return "Siklus Anda (${cycleDuration} hari) cenderung panjang/tidak teratur.";
    }
  }

  // Fungsi untuk mendapatkan perkiraan masa subur
  String _getFertileWindowEstimate() {
    if (_menstrualHistory.isEmpty) {
      return "Catat menstruasi Anda untuk perkiraan masa subur.";
    }

    DateTime lastPeriodStart = _menstrualHistory[0].startDate;
    // Perkiraan ovulasi: rata-rata cycleLength - lutealPhase (sekitar 14 hari)
    // Perkiraan masa subur: 5 hari sebelum ovulasi hingga hari ovulasi
    // Jadi, lastPeriodStart + (averageCycleLength - 19) sampai lastPeriodStart + (averageCycleLength - 14)
    // Contoh: Siklus 28 hari, ovulasi hari ke-14. Masa subur hari ke-10 sampai 14.
    // start: 28 - 19 = 9
    // end: 28 - 14 = 14

    int fertileWindowStartDay = _averageCycleLength - _lutealPhase - 5;
    int fertileWindowEndDay = _averageCycleLength - _lutealPhase;

    if (fertileWindowStartDay < 1) fertileWindowStartDay = 1; // Pastikan tidak kurang dari hari 1

    DateTime fertileStart = lastPeriodStart.add(Duration(days: fertileWindowStartDay));
    DateTime fertileEnd = lastPeriodStart.add(Duration(days: fertileWindowEndDay));

    // Periksa apakah masa subur berikutnya sudah lewat atau belum
    if (fertileEnd.isBefore(DateTime.now())) {
      // Jika masa subur sudah lewat, coba prediksi untuk siklus selanjutnya
      fertileStart = fertileStart.add(Duration(days: _averageCycleLength));
      fertileEnd = fertileEnd.add(Duration(days: _averageCycleLength));
      return "Perkiraan masa subur berikutnya: \n"
             "${DateFormat('dd MMMM yyyy').format(fertileStart)} - ${DateFormat('dd MMMM yyyy').format(fertileEnd)}"; // FIX: yyyy for year
    } else {
      return "Perkiraan masa subur Anda berikutnya: \n"
             "${DateFormat('dd MMMM yyyy').format(fertileStart)} - ${DateFormat('dd MMMM yyyy').format(fertileEnd)}"; // FIX: yyyy for year
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Siklusku'),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bagian Informasi Siklus
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.pink.shade50,
              borderRadius: BorderRadius.circular(15.0),
              border: Border.all(color: Colors.pink.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Ringkasan Siklus Anda",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Icon(Icons.circle_notifications, color: Colors.orange.shade600),
                  title: const Text("Status Siklus:"),
                  subtitle: Text(
                    _getCycleStatus(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.favorite, color: Colors.red.shade400),
                  title: const Text("Perkiraan Masa Subur:"),
                  subtitle: Text(
                    _getFertileWindowEstimate(),
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Catatan: Perkiraan ini adalah rata-rata. Konsultasikan dengan profesional kesehatan untuk informasi lebih akurat.",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16),
          // Daftar Riwayat Menstruasi
          Expanded(
            child: _menstrualHistory.isEmpty
                ? const Center(
                    child: Text('Belum ada catatan menstruasi.'),
                  )
                : ListView.builder(
                    itemCount: _menstrualHistory.length,
                    itemBuilder: (context, index) {
                      final data = _menstrualHistory[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mulai: ${DateFormat('dd MMMM yyyy').format(data.startDate)}', // FIX: yyyy for year
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Selesai: ${DateFormat('dd MMMM yyyy').format(data.endDate)}', // FIX: yyyy for year
                                style: const TextStyle(fontSize: 14),
                              ),
                              if (data.symptoms.isNotEmpty)
                                Text(
                                  'Gejala: ${data.symptoms.join(', ')}',
                                  style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                                ),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editEntry(index),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteEntry(index),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 1), // History/Siklusku is at index 1
    );
  }
}