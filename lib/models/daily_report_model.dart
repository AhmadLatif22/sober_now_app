import 'package:cloud_firestore/cloud_firestore.dart';

class DailyReport {
  final String id;
  final String userId;
  final DateTime date;
  final int moodRating; // 1-5
  final int cravingLevel; // 1-5
  final String notes;
  final List<String> triggers;
  final bool attended_meeting;
  final DateTime createdAt;

  DailyReport({
    required this.id,
    required this.userId,
    required this.date,
    required this.moodRating,
    required this.cravingLevel,
    required this.notes,
    required this.triggers,
    required this.attended_meeting,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': Timestamp.fromDate(date),
      'moodRating': moodRating,
      'cravingLevel': cravingLevel,
      'notes': notes,
      'triggers': triggers,
      'attended_meeting': attended_meeting,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory DailyReport.fromMap(Map<String, dynamic> map) {
    return DailyReport(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      moodRating: map['moodRating'] ?? 3,
      cravingLevel: map['cravingLevel'] ?? 3,
      notes: map['notes'] ?? '',
      triggers: List<String>.from(map['triggers'] ?? []),
      attended_meeting: map['attended_meeting'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
