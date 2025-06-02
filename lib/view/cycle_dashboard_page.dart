// lib/view/cycle_dashboard_page.dart

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart'; // Import TableCalendar
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:flutter_application_1/models/menstrual_data.dart'; // Pastikan path ini benar
import 'package:flutter_application_1/services/local_storage_service.dart'; // Pastikan path ini benar

class CycleDashboardPage extends StatefulWidget {
  const CycleDashboardPage({super.key});

  @override
  State<CycleDashboardPage> createState() => _CycleDashboardPageState();
}

class _CycleDashboardPageState extends State<CycleDashboardPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<MenstrualData> _menstrualHistory = [];
  final LocalStorageService _localStorageService = LocalStorageService();
  final int _averageCycleLength = 28; // Durasi siklus rata-rata
  final int _lutealPhaseLength = 14; // Panjang fase luteal (biasanya 14 hari)

  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMenstrualData();
  }

  Future<void> _loadMenstrualData() async {
    _menstrualHistory = await _localStorageService.getMenstrualData();
    _menstrualHistory.sort((a, b) => b.startDate.compareTo(a.startDate)); // Urutkan dari terbaru

    _events = {}; // Reset events
    for (var data in _menstrualHistory) {
      DateTime start = DateTime(data.startDate.year, data.startDate.month, data.startDate.day);
      DateTime end = DateTime(data.endDate.year, data.endDate.month, data.endDate.day);

      // Tambahkan setiap hari menstruasi sebagai event
      for (int i = 0; i <= end.difference(start).inDays; i++) {
        final day = start.add(Duration(days: i));
        _events.putIfAbsent(day, () => []).add('Menstruasi');
      }
    }
    setState(() {}); // Perbarui UI setelah data dimuat
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    // Pastikan perbandingan tanggal hanya pada tahun, bulan, dan hari
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  // --- Fungsi untuk menghitung fase siklus ---
  String _getCyclePhase(DateTime day) {
    if (_menstrualHistory.isEmpty) {
      return 'Belum ada data siklus.';
    }

    // Ambil tanggal menstruasi terakhir yang valid (tidak null)
    final MenstrualData? latestPeriod = _menstrualHistory.isNotEmpty ? _menstrualHistory.first : null;

    if (latestPeriod == null) {
      return 'Catat menstruasi terakhirmu.';
    }

    final DateTime lastPeriodStart = DateTime(latestPeriod.startDate.year, latestPeriod.startDate.month, latestPeriod.startDate.day);
    final DateTime checkDay = DateTime(day.year, day.month, day.day);

    // Jika hari yang diperiksa adalah hari menstruasi
    if (checkDay.isAfter(lastPeriodStart.subtract(const Duration(days: 1))) &&
        checkDay.isBefore(latestPeriod.endDate.add(const Duration(days: 1)))) {
      return 'Fase Menstruasi';
    }

    // Hitung perkiraan siklus berikutnya (misalnya, untuk menentukan kapan ovulasi akan terjadi)
    final DateTime nextPeriodStartEstimate = lastPeriodStart.add(Duration(days: _averageCycleLength));
    final DateTime ovulationEstimate = nextPeriodStartEstimate.subtract(Duration(days: _lutealPhaseLength)); // Ovulasi biasanya 14 hari sebelum menstruasi berikutnya
    final DateTime fertileWindowStart = ovulationEstimate.subtract(const Duration(days: 5)); // 5 hari sebelum ovulasi
    final DateTime fertileWindowEnd = ovulationEstimate.add(const Duration(days: 1)); // Hari ovulasi + 1

    // Perkiraan Fase Folikular
    if (checkDay.isAfter(latestPeriod.endDate) && checkDay.isBefore(fertileWindowStart)) {
      return 'Fase Folikular (pra-ovulasi)';
    }

    // Perkiraan Fase Ovulasi (masa subur)
    if (checkDay.isAfter(fertileWindowStart.subtract(const Duration(days: 1))) &&
        checkDay.isBefore(fertileWindowEnd.add(const Duration(days: 1)))) {
      return 'Fase Ovulasi (Masa Subur)';
    }

    // Perkiraan Fase Luteal
    if (checkDay.isAfter(fertileWindowEnd) && checkDay.isBefore(nextPeriodStartEstimate)) {
      return 'Fase Luteal (pra-menstruasi)';
    }

    // Jika tanggal yang dipilih sudah jauh ke masa depan atau masa lalu dari data terakhir
    if (checkDay.isAfter(nextPeriodStartEstimate)) {
      return 'Perkiraan siklus berikutnya: ${DateFormat('dd MMMM yyyy').format(nextPeriodStartEstimate)}';
    }

    return 'Di luar siklus yang dapat diprediksi dari data terakhir.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // Latar belakang yang konsisten
      appBar: AppBar(
        title: const Text(
          'Dashboard Siklus',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.pink,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView( // <<--- Tambahkan ini
        child: Column(
          children: [
            // Kalender
            Card(
              margin: const EdgeInsets.all(8.0),
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: TableCalendar(
                firstDay: DateTime.utc(2000, 1, 1),
                lastDay: DateTime.utc(2050, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay; // update `_focusedDay` as well
                  });
                  // Tampilkan detail fase siklus saat tanggal dipilih
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Hari ${DateFormat('dd MMMM yyyy').format(selectedDay)}: ${_getCyclePhase(selectedDay)}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  _focusedDay = focusedDay;
                },
                eventLoader: _getEventsForDay, // Menggunakan fungsi untuk menampilkan event
                calendarStyle: const CalendarStyle( // Menambahkan const
                  todayDecoration: BoxDecoration(
                    color: Color.fromARGB(128, 255, 192, 203), // pink dengan opacity 0.5 (128/255)
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.pink, // Warna untuk tanggal yang dipilih
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.redAccent, // Warna marker untuk event (menstruasi)
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(color: Colors.red), // Warna teks untuk weekend
                ),
                headerStyle: const HeaderStyle( // Menambahkan const
                  formatButtonVisible: false, // Sembunyikan tombol format
                  titleCentered: true,
                  titleTextStyle: TextStyle(color: Colors.pink, fontSize: 18.0, fontWeight: FontWeight.bold),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.pink), // Menggunakan const
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.pink), // Menggunakan const
                ),
              ),
            ),
            const SizedBox(height: 20),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fase Siklus pada ${_selectedDay != null ? DateFormat('dd MMMM yyyy').format(_selectedDay!) : 'Pilih Tanggal'}:',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                    ),
                    const SizedBox(height: 10),
                    if (_selectedDay != null)
                      Text(
                        _getCyclePhase(_selectedDay!),
                        style: const TextStyle(fontSize: 16, color: Colors.black87),
                      )
                    else
                      const Text(
                        'Silakan pilih tanggal di kalender untuk melihat detail fase siklus.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    const SizedBox(height: 20),
                    // Tampilkan ringkasan data menstruasi terakhir
                    const Text(
                      'Riwayat Menstruasi Terakhir:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.pink),
                    ),
                    const SizedBox(height: 10),
                    _menstrualHistory.isEmpty
                        ? const Text('Belum ada riwayat menstruasi.')
                        : SizedBox( // <<--- Ganti Expanded dengan SizedBox jika ingin tinggi tertentu, atau biarkan Listview.builder mengambil tinggi natural
                            height: 150, // <<--- Contoh tinggi, sesuaikan kebutuhan Anda
                            child: ListView.builder(
                              shrinkWrap: true, // <<--- Penting: agar ListView.builder hanya mengambil tinggi yang dibutuhkan
                              physics: const AlwaysScrollableScrollPhysics(), // Selalu bisa di-scroll
                              itemCount: _menstrualHistory.length, // Tampilkan semua riwayat
                              itemBuilder: (context, index) {
                                final data = _menstrualHistory[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    '${DateFormat('dd MMM yyyy').format(data.startDate)} - ${DateFormat('dd MMM yyyy').format(data.endDate)} (${data.symptoms.join(', ')})',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
             const SizedBox(height: 16.0), 
          ],
        ),
      ),
    );
  }
}