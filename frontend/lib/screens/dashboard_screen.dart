import 'package:flutter/material.dart';
import 'daily_questionnaire_screen.dart';
import 'weekly_questionnaire_screen.dart';
import 'monthly_questionnaire_screen.dart';
import '../widgets/lars_line_chart.dart';

// Import TimePeriod enum
import '../widgets/lars_line_chart.dart' show TimePeriod;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 0: daily, 1: weekly, 2: monthly
  int nextQuestionnaire = 0;
  bool isTodayFilled = false; // TODO: Replace with real check for today's questionnaire status

  void _openNextQuestionnaire(BuildContext context) async {
    Widget screen;
    if (nextQuestionnaire == 0) {
      screen = const DailyQuestionnaireScreen();
    } else if (nextQuestionnaire == 1) {
      screen = const WeeklyQuestionnaireScreen();
    } else {
      screen = const MonthlyQuestionnaireScreen();
    }
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    setState(() {
      nextQuestionnaire = (nextQuestionnaire + 1) % 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const StatisticsSection(),
            const SizedBox(height: 32),
            const Text(
              "Today's Questionnaire",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 16),
            if (!isTodayFilled) ...[
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Not filled yet',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[400],
                    foregroundColor: Colors.black,
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _openNextQuestionnaire(context),
                  child: const Text('Fill It Now'),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Filled',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),
            // Test buttons for all questionnaires (могут остаться для ручного теста)
          ],
        ),
      ),
    );
  }
}

class StatisticsSection extends StatefulWidget {
  const StatisticsSection({super.key});

  @override
  State<StatisticsSection> createState() => _StatisticsSectionState();
}

class _StatisticsSectionState extends State<StatisticsSection> {
  String _selectedPeriod = 'weekly';

  String _getStatisticsText(String period) {
    switch (period) {
      case 'weekly':
        return 'Average LARS Score improved by 12% over the last 20 weeks';
      case 'monthly':
        return 'Average LARS Score improved by 8% over the last 12 months';
      case 'yearly':
        return 'Average LARS Score improved by 15% over the last 5 years';
      default:
        return 'Average LARS Score improved by 12% over the last 20 weeks';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 18),
        LarsLineChart(
          onPeriodChanged: (period) {
            setState(() {
              switch (period) {
                case TimePeriod.weekly:
                  _selectedPeriod = 'weekly';
                  break;
                case TimePeriod.monthly:
                  _selectedPeriod = 'monthly';
                  break;
                case TimePeriod.yearly:
                  _selectedPeriod = 'yearly';
                  break;
              }
            });
          },
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getStatisticsText(_selectedPeriod),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 