import 'package:flutter/material.dart';
import 'daily_questionnaire_screen.dart';
import 'weekly_questionnaire_screen.dart';
import 'monthly_questionnaire_screen.dart';
import 'eq5d5l_questionnaire_screen.dart';
import '../widgets/lars_line_chart.dart';
import '../services/api_service.dart';

// Import TimePeriod enum
import '../widgets/lars_line_chart.dart' show TimePeriod;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // 0: daily, 1: weekly, 2: monthly, 3: eq5d5l
  int nextQuestionnaire = 0;
  bool isTodayFilled = false; // TODO: Replace with real check for today's questionnaire status

  void _openNextQuestionnaire(BuildContext context) async {
    Widget screen;
    if (nextQuestionnaire == 0) {
      screen = const DailyQuestionnaireScreen();
    } else if (nextQuestionnaire == 1) {
      screen = const WeeklyQuestionnaireScreen();
    } else if (nextQuestionnaire == 2) {
      screen = const MonthlyQuestionnaireScreen();
    } else {
      screen = const Eq5d5lQuestionnaireScreen();
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    setState(() {
      nextQuestionnaire = (nextQuestionnaire + 1) % 4;
    });
    // Refresh statistics when returning from questionnaire (especially after weekly/LARS)
    // This will automatically reload when the StatisticsSection rebuilds or period changes
    // Data will be refreshed on next period change or when graph reloads
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
  List<Map<String, dynamic>>? _larsData;
  bool _isLoadingStats = false;

  Future<void> _loadStatistics(String period) async {
    setState(() {
      _isLoadingStats = true;
    });

    try {
      final api = ApiService();
      final patientCode = await api.getPatientCode();
      
      if (patientCode == null || patientCode.isEmpty) {
        setState(() {
          _larsData = null;
          _isLoadingStats = false;
        });
        return;
      }

      final response = await api.getLarsData(
        patientCode: patientCode,
        period: period,
      );

      if (response['status'] == 'ok' && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        setState(() {
          _larsData = dataList.cast<Map<String, dynamic>>();
          _isLoadingStats = false;
        });
      } else {
        setState(() {
          _larsData = null;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      setState(() {
        _larsData = null;
        _isLoadingStats = false;
      });
    }
  }

  String _getStatisticsText(String period) {
    if (_larsData == null || _larsData!.isEmpty) {
      switch (period) {
        case 'weekly':
          return 'Complete weekly questionnaires to see your LARS score statistics';
        case 'monthly':
          return 'Complete weekly questionnaires to see your LARS score statistics';
        case 'yearly':
          return 'Complete weekly questionnaires to see your LARS score statistics';
        default:
          return 'Complete weekly questionnaires to see your LARS score statistics';
      }
    }

    final scores = _larsData!
        .where((item) => item['score'] != null)
        .map((item) => (item['score'] as num).toDouble())
        .toList();

    if (scores.length < 2) {
      switch (period) {
        case 'weekly':
          return 'Complete more weekly questionnaires to see improvement trends';
        case 'monthly':
          return 'Complete more weekly questionnaires to see improvement trends';
        case 'yearly':
          return 'Complete more weekly questionnaires to see improvement trends';
        default:
          return 'Complete more weekly questionnaires to see improvement trends';
      }
    }

    final firstScore = scores.first;
    final lastScore = scores.last;
    final improvement = firstScore - lastScore;
    final improvementPercent = (improvement / firstScore * 100).abs();

    final periodText = period == 'weekly' 
        ? 'weeks' 
        : period == 'monthly' 
            ? 'months' 
            : 'years';
    
    final countText = period == 'weekly' 
        ? '${_larsData!.length} weeks'
        : period == 'monthly' 
            ? '${_larsData!.length} months'
            : '${_larsData!.length} years';

    if (improvement > 0) {
      return 'Average LARS Score improved by ${improvementPercent.toStringAsFixed(1)}% (${firstScore.toStringAsFixed(0)} → ${lastScore.toStringAsFixed(0)}) over the last $countText';
    } else if (improvement < 0) {
      return 'Average LARS Score changed by ${improvementPercent.toStringAsFixed(1)}% (${firstScore.toStringAsFixed(0)} → ${lastScore.toStringAsFixed(0)}) over the last $countText';
    } else {
      return 'Average LARS Score is stable at ${lastScore.toStringAsFixed(0)} over the last $countText';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadStatistics(_selectedPeriod);
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
            String newPeriod;
            switch (period) {
              case TimePeriod.weekly:
                newPeriod = 'weekly';
                break;
              case TimePeriod.monthly:
                newPeriod = 'monthly';
                break;
              case TimePeriod.yearly:
                newPeriod = 'yearly';
                break;
            }
            setState(() {
              _selectedPeriod = newPeriod;
            });
            _loadStatistics(newPeriod);
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
              Icon(
                _larsData != null && _larsData!.isNotEmpty && _larsData!.where((item) => item['score'] != null).length >= 2
                    ? (_getStatisticsText(_selectedPeriod).contains('improved') 
                        ? Icons.trending_up 
                        : _getStatisticsText(_selectedPeriod).contains('stable')
                            ? Icons.trending_flat
                            : Icons.trending_down)
                    : Icons.info_outline,
                color: _larsData != null && _larsData!.isNotEmpty && _larsData!.where((item) => item['score'] != null).length >= 2
                    ? (_getStatisticsText(_selectedPeriod).contains('improved') 
                        ? Colors.green 
                        : _getStatisticsText(_selectedPeriod).contains('stable')
                            ? Colors.orange
                            : Colors.red)
                    : Colors.grey,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _isLoadingStats
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
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