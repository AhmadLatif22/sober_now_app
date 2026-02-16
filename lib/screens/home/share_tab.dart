import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/auth_provider.dart';

class ShareTab extends StatelessWidget {
  const ShareTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Your Journey'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.userModel;
          
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final sobrietyDays = user.sobrietyDays;
          final moneySaved = user.moneySaved;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Share Your Progress',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Inspire others with your journey',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Share Cards
                _buildShareCard(
                  context,
                  'Share Sobriety Streak',
                  'I\'m $sobrietyDays days sober! 🎉',
                  'Share your sobriety milestone',
                  Icons.local_fire_department,
                  Colors.orange,
                  () => _shareProgress(
                    context,
                    'I\'m $sobrietyDays days sober! Every day is a victory. 🎉 #SoberNow #Recovery',
                  ),
                ),
                const SizedBox(height: 16),
                _buildShareCard(
                  context,
                  'Share Money Saved',
                  'I\'ve saved \$${moneySaved.toStringAsFixed(2)}! 💰',
                  'Share your financial progress',
                  Icons.savings,
                  Colors.green,
                  () => _shareProgress(
                    context,
                    'I\'ve saved \$${moneySaved.toStringAsFixed(2)} by staying sober! 💰 #SoberNow #FinancialFreedom',
                  ),
                ),
                const SizedBox(height: 16),
                _buildShareCard(
                  context,
                  'Share the App',
                  'Help others start their journey',
                  'Invite friends to join Sober Now',
                  Icons.people,
                  Colors.blue,
                  () => _shareApp(context),
                ),
                const SizedBox(height: 32),

                // Motivational Message
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.lightbulb,
                            color: Color(0xFF00897B),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Why Share?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00897B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Sharing your progress can inspire others who are struggling. '
                        'Your journey matters and can make a difference in someone\'s life.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
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
    );
  }

  Widget _buildShareCard(
    BuildContext context,
    String title,
    String subtitle,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00897B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  void _shareProgress(BuildContext context, String message) {
    Share.share(message);
  }

  void _shareApp(BuildContext context) {
    Share.share(
      'Join me on Sober Now - an app that helps you track your sobriety journey and stay motivated! 🎉',
    );
  }
}
