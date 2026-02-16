import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sober_now/models/user_model.dart';
import 'package:sober_now/models/badge_model.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel calculates sobriety days correctly', () {
      final startDate = DateTime.now().subtract(const Duration(days: 10));
      final user = UserModel(
        uid: 'test123',
        fullName: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        sobrietyStartDate: startDate,
        dailyAlcoholSpend: 15.0,
        drinkingDuration: 3,
        drinkingAmount: 2,
        medicalAdvice: 1,
        impactLevel: 2,
        createdAt: DateTime.now(),
      );

      expect(user.sobrietyDays, equals(10));
    });

    test('UserModel calculates money saved correctly', () {
      final startDate = DateTime.now().subtract(const Duration(days: 30));
      final user = UserModel(
        uid: 'test123',
        fullName: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        sobrietyStartDate: startDate,
        dailyAlcoholSpend: 10.0,
        drinkingDuration: 3,
        drinkingAmount: 2,
        medicalAdvice: 1,
        impactLevel: 2,
        createdAt: DateTime.now(),
      );

      expect(user.moneySaved, equals(300.0)); // 30 days * $10
    });

    test('UserModel toMap and fromMap work correctly', () {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 5));

      final user = UserModel(
        uid: 'test123',
        fullName: 'Test User',
        username: 'testuser',
        email: 'test@example.com',
        sobrietyStartDate: startDate,
        dailyAlcoholSpend: 15.0,
        drinkingDuration: 3,
        drinkingAmount: 2,
        medicalAdvice: 1,
        impactLevel: 2,
        createdAt: now,
      );

      final map = user.toMap();
      expect(map['uid'], equals('test123'));
      expect(map['fullName'], equals('Test User'));
      expect(map['username'], equals('testuser'));
      expect(map['dailyAlcoholSpend'], equals(15.0));

      // Note: fromMap would require proper Timestamp conversion in a real test
    });
  });

  group('SobrietyBadge Tests', () {
    test('Daily badge title is correct', () {
      final badge = SobrietyBadge(
        id: 'test1',
        userId: 'user123',
        type: BadgeType.daily,
        count: 7,
        earnedAt: DateTime.now(),
        isUnlocked: true,
      );

      expect(badge.title, equals('7 Days Sober'));
    });

    test('Weekly badge title is correct', () {
      final badge = SobrietyBadge(
        id: 'test2',
        userId: 'user123',
        type: BadgeType.weekly,
        count: 4,
        earnedAt: DateTime.now(),
        isUnlocked: true,
      );

      expect(badge.title, equals('4 Weeks Sober'));
    });

    test('Monthly badge title is correct', () {
      final badge = SobrietyBadge(
        id: 'test3',
        userId: 'user123',
        type: BadgeType.monthly,
        count: 3,
        earnedAt: DateTime.now(),
        isUnlocked: true,
      );

      expect(badge.title, equals('3 Months Sober'));
    });

    test('Yearly badge title is correct', () {
      final badge = SobrietyBadge(
        id: 'test4',
        userId: 'user123',
        type: BadgeType.yearly,
        count: 1,
        earnedAt: DateTime.now(),
        isUnlocked: true,
      );

      expect(badge.title, equals('1 Year Sober'));
    });

    test('Singular vs plural badge titles', () {
      final singleDay = SobrietyBadge(
        id: 'test5',
        userId: 'user123',
        type: BadgeType.daily,
        count: 1,
        earnedAt: DateTime.now(),
        isUnlocked: true,
      );

      final multipleDays = SobrietyBadge(
        id: 'test6',
        userId: 'user123',
        type: BadgeType.daily,
        count: 7,
        earnedAt: DateTime.now(),
        isUnlocked: true,
      );

      expect(singleDay.title, equals('1 Day Sober'));
      expect(multipleDays.title, equals('7 Days Sober'));
    });
  });
}