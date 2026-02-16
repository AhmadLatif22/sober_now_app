import 'package:flutter/material.dart';
import '../auth/signup_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({Key? key}) : super(key: key);

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  int _currentQuestion = 0;
  int? _question1Answer;
  int? _question2Answer;
  int? _question3Answer;
  int? _question4Answer;

  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How long have you been drinking regularly?',
      'options': [
        'Less than 1 year',
        '1-3 years',
        '4-7 years',
        '8-15 years',
        'More than 15 years',
      ],
    },
    {
      'question': 'How much have you typically been drinking?',
      'options': [
        '1-2 drinks occasionally',
        '3-4 drinks regularly',
        '5-8 drinks daily',
        '9-15 drinks daily',
        'More than 15 drinks daily',
      ],
    },
    {
      'question': 'Have you sought medical advice about your drinking?',
      'options': [
        'No, never considered it',
        'Thought about it but haven\'t',
        'Asked my doctor briefly',
        'Had detailed discussions with healthcare provider',
        'Currently receiving medical support',
      ],
    },
    {
      'question':
          'Has your drinking affected your relationships, work, or finances?',
      'options': [
        'No significant impact',
        'Minor relationship strain',
        'Some job or financial concerns',
        'Lost relationships or job opportunities',
        'Severe losses in multiple areas',
      ],
    },
  ];

  void _selectAnswer(int value) {
    setState(() {
      switch (_currentQuestion) {
        case 0:
          _question1Answer = value;
          break;
        case 1:
          _question2Answer = value;
          break;
        case 2:
          _question3Answer = value;
          break;
        case 3:
          _question4Answer = value;
          break;
      }
    });
  }

  void _nextQuestion() {
    if (_getCurrentAnswer() == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option')),
      );
      return;
    }

    if (_currentQuestion < _questions.length - 1) {
      setState(() {
        _currentQuestion++;
      });
    } else {
      // Navigate to signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpScreen(
            drinkingDuration: _question1Answer!,
            drinkingAmount: _question2Answer!,
            medicalAdvice: _question3Answer!,
            impactLevel: _question4Answer!,
          ),
        ),
      );
    }
  }

  void _previousQuestion() {
    if (_currentQuestion > 0) {
      setState(() {
        _currentQuestion--;
      });
    }
  }

  int? _getCurrentAnswer() {
    switch (_currentQuestion) {
      case 0:
        return _question1Answer;
      case 1:
        return _question2Answer;
      case 2:
        return _question3Answer;
      case 3:
        return _question4Answer;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentAnswer = _getCurrentAnswer();
    final question = _questions[_currentQuestion];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentQuestion > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black87),
                onPressed: _previousQuestion,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestion + 1} of ${_questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    '${(((_currentQuestion + 1) / _questions.length) * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00897B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentQuestion + 1) / _questions.length,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF00897B),
                ),
              ),
              const SizedBox(height: 40),

              // Question
              Text(
                question['question'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 32),

              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: question['options'].length,
                  itemBuilder: (context, index) {
                    final optionValue = index + 1;
                    final isSelected = currentAnswer == optionValue;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _selectAnswer(optionValue),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00897B).withOpacity(0.1)
                                : Colors.grey[100],
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00897B)
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF00897B)
                                      : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF00897B)
                                        : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    optionValue.toString(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[600],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  question['options'][index],
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isSelected
                                        ? const Color(0xFF00897B)
                                        : Colors.black87,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text(
                    _currentQuestion < _questions.length - 1
                        ? 'Tap to continue'
                        : 'Complete',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Privacy Notice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.lock,
                    size: 16,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Your responses are private and secure',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
