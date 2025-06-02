class MenstrualData {
  final DateTime startDate;
  final DateTime endDate;
  final List<String> symptoms; // <<< ADDED THIS LINE

  MenstrualData({
    required this.startDate,
    required this.endDate,
    this.symptoms = const [], // <<< ADDED THIS, with a default empty list
  });

  factory MenstrualData.fromJson(Map<String, dynamic> json) {
    return MenstrualData(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      // Ensure 'symptoms' is handled; if not present, default to empty list
      symptoms: List<String>.from(json['symptoms'] ?? []), // <<< ADDED THIS
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'symptoms': symptoms, // <<< ADDED THIS
    };
  }
}