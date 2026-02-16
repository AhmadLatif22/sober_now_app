import 'package:cloud_firestore/cloud_firestore.dart';

enum BadgeType {
  daily,
  weekly,
  monthly,
  yearly,
}

class SobrietyBadge {
  final String id;
  final String userId;
  final BadgeType type;
  final int count; // e.g., 7 for 7 days, 4 for 4 weeks
  final DateTime earnedAt;
  final bool isUnlocked;

  SobrietyBadge({
    required this.id,
    required this.userId,
    required this.type,
    required this.count,
    required this.earnedAt,
    required this.isUnlocked,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type.toString(),
      'count': count,
      'earnedAt': Timestamp.fromDate(earnedAt),
      'isUnlocked': isUnlocked,
    };
  }

  factory SobrietyBadge.fromMap(Map<String, dynamic> map) {
    return SobrietyBadge(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: BadgeType.values.firstWhere(
            (e) => e.toString() == map['type'],
        orElse: () => BadgeType.daily,
      ),
      count: map['count'] ?? 0,
      earnedAt: (map['earnedAt'] as Timestamp).toDate(),
      isUnlocked: map['isUnlocked'] ?? false,
    );
  }

  String get title {
    switch (type) {
      case BadgeType.daily:
        return '$count Day${count > 1 ? 's' : ''} Sober';
      case BadgeType.weekly:
        return '$count Week${count > 1 ? 's' : ''} Sober';
      case BadgeType.monthly:
        return '$count Month${count > 1 ? 's' : ''} Sober';
      case BadgeType.yearly:
        return '$count Year${count > 1 ? 's' : ''} Sober';
    }
  }

  String get description {
    switch (type) {
      case BadgeType.daily:
        return 'Congratulations on $count day${count > 1 ? 's' : ''} of sobriety!';
      case BadgeType.weekly:
        return 'You\'ve completed $count week${count > 1 ? 's' : ''}!';
      case BadgeType.monthly:
        return 'Amazing! $count month${count > 1 ? 's' : ''} sober!';
      case BadgeType.yearly:
        return 'Incredible milestone: $count year${count > 1 ? 's' : ''}!';
    }
  }
}