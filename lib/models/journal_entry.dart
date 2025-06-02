// lib/models/journal_entry.dart
import 'package:equatable/equatable.dart';

class JournalEntry extends Equatable {
  final String id; // ID unik untuk setiap entri
  final String content;
  final DateTime date;

  const JournalEntry({
    required this.id,
    required this.content,
    required this.date,
  });

  // Factory constructor untuk membuat JournalEntry dari JSON (Map)
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      content: json['content'] as String,
      date: DateTime.parse(json['date'] as String), // Parsing string ISO 8601 ke DateTime
    );
  }

  // Metode untuk mengonversi JournalEntry ke JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'date': date.toIso8601String(), // Mengonversi DateTime ke string ISO 8601
    };
  }

  // Metode copyWith untuk mempermudah perubahan data
  JournalEntry copyWith({
    String? id,
    String? content,
    DateTime? date,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      content: content ?? this.content,
      date: date ?? this.date,
    );
  }

  @override
  List<Object?> get props => [id, content, date];
}