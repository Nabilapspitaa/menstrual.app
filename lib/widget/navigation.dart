// lib/widget/navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/home_page.dart';
import 'package:flutter_application_1/view/history_page.dart';
import 'package:flutter_application_1/view/settings_page.dart';
import 'package:flutter_application_1/view/journal_home_page.dart'; // Import the new JournalHomePage

class CustomNavigationBar extends StatelessWidget {
  final int selectedIndex;

  const CustomNavigationBar({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Colors.pink,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.white,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (selectedIndex == index) return;

        switch (index) {
          case 0: // Home
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage()),
            );
            break;
          case 1: // Siklusku (History)
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HistoryPage()),
            );
            break;
          case 2: // Jurnal Harian
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JournalHomePage()), // Navigate to JournalHomePage
            );
            break;
          case 3: // Pengaturan
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
            break;
          default:
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline),
          label: 'Siklusku',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.edit_note),
          label: 'Jurnal Harian',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Pengaturan',
        ),
      ],
    );
  }
}