import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String username;
  final String email;
  final DateTime sobrietyStartDate;
  final double dailyAlcoholSpend;
  final int drinkingDuration; // Question 1 answer
  final int drinkingAmount; // Question 2 answer
  final int medicalAdvice; // Question 3 answer
  final int impactLevel; // Question 4 answer
  final DateTime createdAt;
  final bool isPremium;
  final DateTime? subscriptionEndDate;

  UserModel({
    required this.uid,
    required this.fullName,
    required this.username,
    required this.email,
    required this.sobrietyStartDate,
    required this.dailyAlcoholSpend,
    required this.drinkingDuration,
    required this.drinkingAmount,
    required this.medicalAdvice,
    required this.impactLevel,
    required this.createdAt,
    this.isPremium = false,
    this.subscriptionEndDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'username': username,
      'email': email,
      'sobrietyStartDate': Timestamp.fromDate(sobrietyStartDate),
      'dailyAlcoholSpend': dailyAlcoholSpend,
      'drinkingDuration': drinkingDuration,
      'drinkingAmount': drinkingAmount,
      'medicalAdvice': medicalAdvice,
      'impactLevel': impactLevel,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPremium': isPremium,
      'subscriptionEndDate': subscriptionEndDate != null 
          ? Timestamp.fromDate(subscriptionEndDate!) 
          : null,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      sobrietyStartDate: (map['sobrietyStartDate'] as Timestamp).toDate(),
      dailyAlcoholSpend: (map['dailyAlcoholSpend'] ?? 0).toDouble(),
      drinkingDuration: map['drinkingDuration'] ?? 1,
      drinkingAmount: map['drinkingAmount'] ?? 1,
      medicalAdvice: map['medicalAdvice'] ?? 1,
      impactLevel: map['impactLevel'] ?? 1,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isPremium: map['isPremium'] ?? false,
      subscriptionEndDate: map['subscriptionEndDate'] != null
          ? (map['subscriptionEndDate'] as Timestamp).toDate()
          : null,
    );
  }

  UserModel copyWith({
    String? fullName,
    String? username,
    String? email,
    DateTime? sobrietyStartDate,
    double? dailyAlcoholSpend,
    bool? isPremium,
    DateTime? subscriptionEndDate,
  }) {
    return UserModel(
      uid: uid,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      sobrietyStartDate: sobrietyStartDate ?? this.sobrietyStartDate,
      dailyAlcoholSpend: dailyAlcoholSpend ?? this.dailyAlcoholSpend,
      drinkingDuration: drinkingDuration,
      drinkingAmount: drinkingAmount,
      medicalAdvice: medicalAdvice,
      impactLevel: impactLevel,
      createdAt: createdAt,
      isPremium: isPremium ?? this.isPremium,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
    );
  }

  int get sobrietyDays {
    final now = DateTime.now();
    final difference = now.difference(sobrietyStartDate);
    return difference.inDays;
  }

  double get moneySaved {
    return sobrietyDays * dailyAlcoholSpend;
  }
}
