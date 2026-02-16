import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/daily_report_model.dart';
import '../models/badge_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DailyReport> _reports = [];
  List<SobrietyBadge> _badges = [];
  bool _isLoading = false;

  List<DailyReport> get reports => _reports;
  List<SobrietyBadge> get badges => _badges;
  bool get isLoading => _isLoading;

  Future<void> loadUserReports(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('daily_reports')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      _reports = snapshot.docs
          .map((doc) => DailyReport.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error loading reports: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> saveDailyReport({
    required String userId,
    required int moodRating,
    required int cravingLevel,
    required String notes,
    required List<String> triggers,
    required bool attendedMeeting,
  }) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Check if report already exists for today
      final existingQuery = await _firestore
          .collection('daily_reports')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: Timestamp.fromDate(today))
          .get();

      final reportId = existingQuery.docs.isNotEmpty
          ? existingQuery.docs.first.id
          : _firestore.collection('daily_reports').doc().id;

      final report = DailyReport(
        id: reportId,
        userId: userId,
        date: today,
        moodRating: moodRating,
        cravingLevel: cravingLevel,
        notes: notes,
        triggers: triggers,
        attended_meeting: attendedMeeting,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('daily_reports')
          .doc(reportId)
          .set(report.toMap());

      await loadUserReports(userId);
      return true;
    } catch (e) {
      debugPrint('Error saving report: $e');
      return false;
    }
  }

  Future<void> loadUserBadges(String userId, int sobrietyDays) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Calculate which badges should be unlocked
      final badgesToUnlock = <SobrietyBadge>[];

      // Daily badges (1, 7, 14, 21, 30, 60, 90 days)
      final dailyMilestones = [1, 7, 14, 21, 30, 60, 90];
      for (var milestone in dailyMilestones) {
        if (sobrietyDays >= milestone) {
          badgesToUnlock.add(SobrietyBadge(
            id: 'daily_$milestone',
            userId: userId,
            type: BadgeType.daily,
            count: milestone,
            earnedAt: DateTime.now(),
            isUnlocked: true,
          ));
        }
      }

      // Weekly badges
      final weeks = sobrietyDays ~/ 7;
      if (weeks > 0) {
        for (var i = 1; i <= weeks && i <= 52; i++) {
          badgesToUnlock.add(SobrietyBadge(
            id: 'weekly_$i',
            userId: userId,
            type: BadgeType.weekly,
            count: i,
            earnedAt: DateTime.now(),
            isUnlocked: true,
          ));
        }
      }

      // Monthly badges
      final months = sobrietyDays ~/ 30;
      if (months > 0) {
        for (var i = 1; i <= months && i <= 12; i++) {
          badgesToUnlock.add(SobrietyBadge(
            id: 'monthly_$i',
            userId: userId,
            type: BadgeType.monthly,
            count: i,
            earnedAt: DateTime.now(),
            isUnlocked: true,
          ));
        }
      }

      // Yearly badges
      final years = sobrietyDays ~/ 365;
      if (years > 0) {
        for (var i = 1; i <= years && i <= 10; i++) {
          badgesToUnlock.add(SobrietyBadge(
            id: 'yearly_$i',
            userId: userId,
            type: BadgeType.yearly,
            count: i,
            earnedAt: DateTime.now(),
            isUnlocked: true,
          ));
        }
      }

      // Save badges to Firestore
      for (var badge in badgesToUnlock) {
        await _firestore
            .collection('badges')
            .doc(badge.id)
            .set(badge.toMap(), SetOptions(merge: true));
      }

      // Load all badges
      final snapshot = await _firestore
          .collection('badges')
          .where('userId', isEqualTo: userId)
          .get();

      _badges = snapshot.docs
          .map((doc) => SobrietyBadge.fromMap(doc.data()))
          .toList();

      // Sort badges
      _badges.sort((a, b) {
        final typeOrder = [
          BadgeType.daily,
          BadgeType.weekly,
          BadgeType.monthly,
          BadgeType.yearly
        ];
        final typeComparison = typeOrder
            .indexOf(a.type)
            .compareTo(typeOrder.indexOf(b.type));
        if (typeComparison != 0) return typeComparison;
        return b.count.compareTo(a.count);
      });
    } catch (e) {
      debugPrint('Error loading badges: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  DailyReport? getTodayReport() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    try {
      return _reports.firstWhere(
            (report) {
          final reportDate = DateTime(
            report.date.year,
            report.date.month,
            report.date.day,
          );
          return reportDate.isAtSameMomentAs(today);
        },
      );
    } catch (e) {
      return null;
    }
  }

  bool hasTodayReport() {
    return getTodayReport() != null;
  }
}