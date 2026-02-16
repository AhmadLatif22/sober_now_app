import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/subscription_provider.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userModel;
          
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (user.isPremium) {
            return _buildPremiumStatus(context, user, authProvider);
          } else {
            return _buildUpgradeOptions(context, authProvider);
          }
        },
      ),
    );
  }

  Widget _buildPremiumStatus(BuildContext context, dynamic user, AuthProvider authProvider) {
    final subscriptionEndDate = user.subscriptionEndDate;
    final daysRemaining = subscriptionEndDate != null
        ? subscriptionEndDate.difference(DateTime.now()).inDays
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Premium Badge
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.star,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Premium Member',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have access to all features',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Subscription Details
          _buildInfoCard(
            'Subscription Status',
            'Active',
            Icons.check_circle,
            Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            'Next Billing Date',
            subscriptionEndDate != null
                ? DateFormat('MMM dd, yyyy').format(subscriptionEndDate)
                : 'N/A',
            Icons.calendar_today,
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            'Days Remaining',
            '$daysRemaining days',
            Icons.timelapse,
            Colors.orange,
          ),
          const SizedBox(height: 32),

          // Premium Features
          const Text(
            'Premium Features',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('Unlimited daily reports'),
          _buildFeatureItem('Advanced analytics'),
          _buildFeatureItem('Custom goals and reminders'),
          _buildFeatureItem('Export your data'),
          _buildFeatureItem('Priority support'),
          _buildFeatureItem('Ad-free experience'),
          const SizedBox(height: 32),

          // Cancel Subscription Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _showCancelDialog(context, authProvider),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
              child: const Text('Cancel Subscription'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpgradeOptions(BuildContext context, AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upgrade to Premium',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock all features and get the most out of Sober Now',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),

          // Premium Plan Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00897B), Color(0xFF004D40)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00897B).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 32),
                    SizedBox(width: 8),
                    Text(
                      'Premium Plan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '\$10.99',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Padding(
                      padding: EdgeInsets.only(top: 16.0),
                      child: Text(
                        '/month',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Auto-renews every 30 days',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Features
          const Text(
            'What You Get',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem('Unlimited daily reports'),
          _buildFeatureItem('Advanced analytics and insights'),
          _buildFeatureItem('Custom goals and reminders'),
          _buildFeatureItem('Export your data anytime'),
          _buildFeatureItem('Priority customer support'),
          _buildFeatureItem('Ad-free experience'),
          _buildFeatureItem('Access to premium badges'),
          const SizedBox(height: 32),

          // Subscribe Button
          SizedBox(
            width: double.infinity,
            child: Consumer<SubscriptionProvider>(
              builder: (context, subscriptionProvider, child) {
                return ElevatedButton(
                  onPressed: subscriptionProvider.isLoading
                      ? null
                      : () => _subscribe(context, authProvider, subscriptionProvider),
                  child: subscriptionProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Subscribe Now',
                          style: TextStyle(fontSize: 18),
                        ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Terms
          Text(
            'By subscribing, you agree to our Terms of Service. '
            'Subscription will automatically renew unless cancelled at least 24 hours before the end of the current period.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF00897B),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _subscribe(
    BuildContext context,
    AuthProvider authProvider,
    SubscriptionProvider subscriptionProvider,
  ) async {
    if (authProvider.user == null) return;

    final success = await subscriptionProvider.subscribeToPremium(
      authProvider.user!.uid,
    );

    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully subscribed to Premium!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              subscriptionProvider.errorMessage ?? 'Failed to subscribe',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text(
          'Are you sure you want to cancel your subscription? '
          'You will still have access until the end of your billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Subscription'),
          ),
          TextButton(
            onPressed: () async {
              final subscriptionProvider = Provider.of<SubscriptionProvider>(
                context,
                listen: false,
              );
              final success = await subscriptionProvider.cancelSubscription(
                authProvider.user!.uid,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subscription cancelled'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to cancel subscription'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Cancel Subscription',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
