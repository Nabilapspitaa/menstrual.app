import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/menstrual_data.dart';
import 'package:flutter_application_1/services/local_storage_service.dart';
import 'package:flutter_application_1/view/login.dart';
import 'package:flutter_application_1/view/notification.dart';
import 'package:flutter_application_1/view/cycle_dashboard_page.dart';
import 'package:flutter_application_1/widget/navigation.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<MenstrualData> _menstrualHistory = [];
  DateTime? _lastPeriodStartDate;
  DateTime? _nextPeriodEstimate;
  final LocalStorageService _localStorageService = LocalStorageService();
  final int _averageCycleLength = 28;
  String _userName = 'Pengguna';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadUserData();
    await _loadMenstrualData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Pengguna';
    });
  }

  Future<void> _loadMenstrualData() async {
    _menstrualHistory = await _localStorageService.getMenstrualData();
    _menstrualHistory.sort((a, b) => b.startDate.compareTo(a.startDate));
    if (_menstrualHistory.isNotEmpty) {
      _lastPeriodStartDate = _menstrualHistory.first.startDate;
      _calculateNextPeriod();
    }
    setState(() {});
  }

  void _calculateNextPeriod() {
    if (_lastPeriodStartDate != null) {
      _nextPeriodEstimate = _lastPeriodStartDate!.add(Duration(days: _averageCycleLength));
    }
  }

  void _addPeriodEntry(DateTime startDate, DateTime endDate, List<String> symptoms) {
    setState(() {
      _menstrualHistory.add(MenstrualData(startDate: startDate, endDate: endDate, symptoms: symptoms));
      _menstrualHistory.sort((a, b) => b.startDate.compareTo(a.startDate));
      _lastPeriodStartDate = _menstrualHistory.first.startDate;
      _calculateNextPeriod();
    });
    _localStorageService.saveMenstrualData(_menstrualHistory);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Catatan menstruasi berhasil ditambahkan!')),
      );
    }
  }

  void _showAddPeriodDialog() {
    DateTime tempStartDate = DateTime.now();
    DateTime tempEndDate = DateTime.now();
    List<String> tempSymptoms = [];
    final List<String> allSymptoms = ['Kram', 'Sakit Kepala', 'Kembung', 'Lelah', 'Mood Swing', 'Jerawat'];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Catat Menstruasi'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      title: Text("Tanggal Mulai: ${DateFormat('dd MMMM yyyy').format(tempStartDate)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: tempStartDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            tempStartDate = picked;
                            if (tempEndDate.isBefore(tempStartDate)) {
                              tempEndDate = tempStartDate;
                            }
                          });
                        }
                      },
                    ),
                    ListTile(
                      title: Text("Tanggal Selesai: ${DateFormat('dd MMMM yyyy').format(tempEndDate)}"),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: tempEndDate,
                          firstDate: tempStartDate,
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tempEndDate.isBefore(tempStartDate)) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Tanggal selesai tidak boleh sebelum tanggal mulai!')),
                  );
                  return;
                }
                _addPeriodEntry(tempStartDate, tempEndDate, tempSymptoms);
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Catat'),
            ),
          ],
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Selamat Pagi';
    if (hour >= 12 && hour < 18) return 'Selamat Siang';
    if (hour >= 18 && hour < 22) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Hapus semua data login
    await _localStorageService.setLoggedIn(false);
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        backgroundColor: Colors.pink[50],
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.pink,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_getGreeting()},',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        _userName,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.pink[700]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Bootstrap.bell, color: Colors.black54, size: 28),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const NotificationPage()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Bootstrap.box_arrow_in_right, color: Colors.black54, size: 26),
                      onPressed: () async {
                        final bool? confirmLogout = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Konfirmasi Logout'),
                              content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  child: const Text('Logout', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmLogout == true) {
                          _logout();
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Welcome Banner
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.pink.shade100,
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.spa_outlined, size: 60, color: Colors.white),
                    SizedBox(height: 10),
                    Text(
                      'Selamat Datang!\nMari Pantau Kesehatanmu.',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Slogan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Pantau siklusmu, sayangi tubuhmu ",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Icon(Icons.favorite, color: Colors.pink.shade300, size: 24),
              ],
            ),
            const SizedBox(height: 20),

            // Next Period Estimate
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.pink[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Perkiraan Haid Selanjutnya:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _nextPeriodEstimate != null
                            ? DateFormat('dd MMMM yyyy').format(_nextPeriodEstimate!)
                            : "Belum ada data",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pink[700]),
                      ),
                      const SizedBox(height: 10),
                      const Text("Durasi Siklus: 28 hari", style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_month, color: Colors.pink[700], size: 40),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CycleDashboardPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Add Period Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _showAddPeriodDialog,
                icon: const Icon(Icons.add),
                label: const Text("Catat Menstruasi Terakhir"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomNavigationBar(selectedIndex: 0),
    );
  }
}
