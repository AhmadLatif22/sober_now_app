import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SubscriptionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> subscribeToPremium(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Create payment intent
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': '1099', // $10.99
          'currency': 'usd',
          'payment_method_types[]': 'card',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent');
      }

      final paymentIntent = json.decode(response.body);

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Sober Now',
          style: ThemeMode.light,
        ),
      );

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      // Update user subscription
      final subscriptionEndDate = DateTime.now().add(const Duration(days: 30));
      
      await _firestore.collection('users').doc(userId).update({
        'isPremium': true,
        'subscriptionEndDate': Timestamp.fromDate(subscriptionEndDate),
      });

      // Schedule reminder email (3 days before expiry)
      await _scheduleSubscriptionReminder(userId, subscriptionEndDate);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> _scheduleSubscriptionReminder(
    String userId,
    DateTime subscriptionEndDate,
  ) async {
    final reminderDate = subscriptionEndDate.subtract(const Duration(days: 3));
    
    await _firestore.collection('subscription_reminders').add({
      'userId': userId,
      'reminderDate': Timestamp.fromDate(reminderDate),
      'subscriptionEndDate': Timestamp.fromDate(subscriptionEndDate),
      'sent': false,
    });
  }

  Future<bool> cancelSubscription(String userId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore.collection('users').doc(userId).update({
        'isPremium': false,
        'subscriptionEndDate': null,
      });

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkSubscriptionStatus(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final data = doc.data();
      
      if (data != null && data['isPremium'] == true) {
        final subscriptionEndDate =
            (data['subscriptionEndDate'] as Timestamp?)?.toDate();
        
        if (subscriptionEndDate != null &&
            DateTime.now().isAfter(subscriptionEndDate)) {
          // Subscription expired
          await _firestore.collection('users').doc(userId).update({
            'isPremium': false,
            'subscriptionEndDate': null,
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking subscription: $e');
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
