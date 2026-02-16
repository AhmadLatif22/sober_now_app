import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';

class DailyReportTab extends StatefulWidget {
  const DailyReportTab({Key? key}) : super(key: key);

  @override
  State<DailyReportTab> createState() => _DailyReportTabState();
}

class _DailyReportTabState extends State<DailyReportTab> {
  final _formKey = GlobalKey<FormState>();
  int _moodRating = 3;
  int _cravingLevel = 3;
  final _notesController = TextEditingController();
  final List<String> _selectedTriggers = [];
  bool _attendedMeeting = false;

  final List<String> _triggerOptions = [
    'Stress',
    'Social situation',
    'Loneliness',
    'Boredom',
    'Anxiety',
    'Depression',
    'Work pressure',
    'Family issues',
    'Financial concerns',
    'Other',
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (authProvider.user == null) return;

    final success = await userProvider.saveDailyReport(
      userId: authProvider.user!.uid,
      moodRating: _moodRating,
      cravingLevel: _cravingLevel,
      notes: _notesController.text.trim(),
      triggers: _selectedTriggers,
      attendedMeeting: _attendedMeeting,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Daily report saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reset form
      setState(() {
        _moodRating = 3;
        _cravingLevel = 3;
        _notesController.clear();
        _selectedTriggers.clear();
        _attendedMeeting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Report'),
        backgroundColor: const Color(0xFF00897B),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Consumer<UserProvider>(
          builder: (context, userProvider, child) {
            final todayReport = userProvider.getTodayReport();
            
            if (todayReport != null) {
              return _buildReportCompleted(todayReport);
            }
            
            return _buildReportForm();
          },
        ),
      ),
    );
  }

  Widget _buildReportCompleted(dynamic report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Completed',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You\'ve logged your report for ${DateFormat('MMMM dd, yyyy').format(DateTime.now())}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Today\'s Report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildReportSummary(report),
      ],
    );
  }

  Widget _buildReportSummary(dynamic report) {
    return Column(
      children: [
        _buildSummaryCard('Mood Rating', '${report.moodRating}/5', Icons.mood),
        const SizedBox(height: 12),
        _buildSummaryCard('Craving Level', '${report.cravingLevel}/5', Icons.favorite),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Attended Meeting',
          report.attended_meeting ? 'Yes' : 'No',
          Icons.group,
        ),
        if (report.triggers.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildSummaryCard(
            'Triggers',
            report.triggers.join(', '),
            Icons.warning,
          ),
        ],
        if (report.notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.notes, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report.notes,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
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

  Widget _buildReportForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Mood Rating
          const Text(
            'Mood Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              final rating = index + 1;
              return InkWell(
                onTap: () {
                  setState(() {
                    _moodRating = rating;
                  });
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _moodRating == rating
                        ? const Color(0xFF00897B)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getMoodIcon(rating),
                        color: _moodRating == rating
                            ? Colors.white
                            : Colors.grey[600],
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rating.toString(),
                        style: TextStyle(
                          color: _moodRating == rating
                              ? Colors.white
                              : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Craving Level
          const Text(
            'Craving Level',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Slider(
            value: _cravingLevel.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: const Color(0xFF00897B),
            label: _cravingLevel.toString(),
            onChanged: (value) {
              setState(() {
                _cravingLevel = value.toInt();
              });
            },
          ),
          Text(
            'Level: $_cravingLevel/5',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Triggers
          const Text(
            'Any triggers today?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _triggerOptions.map((trigger) {
              final isSelected = _selectedTriggers.contains(trigger);
              return FilterChip(
                label: Text(trigger),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTriggers.add(trigger);
                    } else {
                      _selectedTriggers.remove(trigger);
                    }
                  });
                },
                selectedColor: const Color(0xFF00897B).withOpacity(0.3),
                checkmarkColor: const Color(0xFF00897B),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Attended Meeting
          CheckboxListTile(
            title: const Text('Did you attend a support meeting today?'),
            value: _attendedMeeting,
            activeColor: const Color(0xFF00897B),
            onChanged: (value) {
              setState(() {
                _attendedMeeting = value ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),

          // Notes
          const Text(
            'Additional Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _notesController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'How was your day? Any challenges or victories?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Submit Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveReport,
              child: const Text(
                'Save Report',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMoodIcon(int rating) {
    switch (rating) {
      case 1:
        return Icons.sentiment_very_dissatisfied;
      case 2:
        return Icons.sentiment_dissatisfied;
      case 3:
        return Icons.sentiment_neutral;
      case 4:
        return Icons.sentiment_satisfied;
      case 5:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.sentiment_neutral;
    }
  }
}
