import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../subscription/subscription_screen.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.userModel;
        
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final sobrietyDays = user.sobrietyDays;
        final moneySaved = user.moneySaved;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Sober Now'),
            backgroundColor: const Color(0xFF00897B),
            foregroundColor: Colors.white,
            actions: [
              if (!user.isPremium)
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star, color: Colors.amber),
                  label: const Text(
                    'Go Premium',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                Text(
                  'Hello, ${user.fullName.split(' ').first}!',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep up the great work!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Sobriety Streak Card
                Container(
                  width: double.infinity,
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
                    children: [
                      const Text(
                        'Sobriety Streak',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            sobrietyDays.toString(),
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Text(
                              sobrietyDays == 1 ? 'Day' : 'Days',
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Since ${DateFormat('MMM dd, yyyy').format(user.sobrietyStartDate)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Statistics Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Money Saved',
                        '\$${moneySaved.toStringAsFixed(2)}',
                        Icons.savings,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Daily Reports',
                        Provider.of<UserProvider>(context).reports.length.toString(),
                        Icons.assignment_turned_in,
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Badges Earned',
                        Provider.of<UserProvider>(context).badges.length.toString(),
                        Icons.emoji_events,
                        Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        'Plan',
                        user.isPremium ? 'Premium' : 'Free',
                        Icons.card_membership,
                        user.isPremium ? Colors.purple : Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Today's Report Status
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final hasTodayReport = userProvider.hasTodayReport();
                    
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: hasTodayReport
                            ? Colors.green[50]
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasTodayReport
                              ? Colors.green[200]!
                              : Colors.orange[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            hasTodayReport
                                ? Icons.check_circle
                                : Icons.pending_actions,
                            color: hasTodayReport
                                ? Colors.green
                                : Colors.orange,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  hasTodayReport
                                      ? 'Daily Report Completed'
                                      : 'Daily Report Pending',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: hasTodayReport
                                        ? Colors.green[900]
                                        : Colors.orange[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  hasTodayReport
                                      ? 'Great job! You\'ve logged today\'s report.'
                                      : 'Don\'t forget to log your daily report.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: hasTodayReport
                                        ? Colors.green[700]
                                        : Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Motivational Quote
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.format_quote, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Daily Inspiration',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getMotivationalQuote(sobrietyDays),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationalQuote(int days) {
    if (days < 7) {
      return "One day at a time. You're doing great!";
    } else if (days < 30) {
      return "Every day sober is a victory. Keep going!";
    } else if (days < 90) {
      return "You're building a new life, one day at a time.";
    } else if (days < 365) {
      return "Your strength is inspiring. Keep pushing forward!";
    } else {
      return "You've proven your strength. Keep shining!";
    }
  }
}
