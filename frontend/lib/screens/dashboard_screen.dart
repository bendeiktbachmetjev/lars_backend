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
  String? _nextQuestionnaireType; // "daily", "weekly", "monthly", "eq5d5l", or null
  bool _isTodayFilled = false;
  bool _isLoadingQuestionnaire = true;
  String? _questionnaireReason;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNextQuestionnaire();
  }

  Future<void> _loadNextQuestionnaire() async {
    setState(() {
      _isLoadingQuestionnaire = true;
      _errorMessage = null;
    });

    try {
      final api = ApiService();
      final patientCode = await api.getPatientCode();
      
      if (patientCode == null || patientCode.isEmpty) {
        setState(() {
          _nextQuestionnaireType = null;
          _isTodayFilled = false;
          _isLoadingQuestionnaire = false;
          _errorMessage = 'Please set your patient code in Profile';
        });
        return;
      }

      final response = await api.getNextQuestionnaire(patientCode: patientCode);

      if (response['status'] == 'ok') {
        setState(() {
          _nextQuestionnaireType = response['questionnaire_type'];
          _isTodayFilled = response['is_today_filled'] ?? false;
          _questionnaireReason = response['reason'];
          _isLoadingQuestionnaire = false;
        });
      } else {
        setState(() {
          _nextQuestionnaireType = null;
          _isTodayFilled = false;
          _isLoadingQuestionnaire = false;
          _errorMessage = 'Failed to load questionnaire info';
        });
      }
    } catch (e) {
      setState(() {
        _nextQuestionnaireType = null;
        _isTodayFilled = false;
        _isLoadingQuestionnaire = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  void _openNextQuestionnaire(BuildContext context) async {
    if (_nextQuestionnaireType == null) {
      return;
    }

    Widget screen;
    switch (_nextQuestionnaireType) {
      case 'daily':
        screen = const DailyQuestionnaireScreen();
        break;
      case 'weekly':
        screen = const WeeklyQuestionnaireScreen();
        break;
      case 'monthly':
        screen = const MonthlyQuestionnaireScreen();
        break;
      case 'eq5d5l':
        screen = const Eq5d5lQuestionnaireScreen();
        break;
      default:
        return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );

    // Reload questionnaire info after returning from questionnaire
    await _loadNextQuestionnaire();
  }

  String _getQuestionnaireName() {
    switch (_nextQuestionnaireType) {
      case 'daily':
        return 'Daily Questionnaire';
      case 'weekly':
        return 'Weekly Questionnaire (LARS)';
      case 'monthly':
        return 'Monthly Questionnaire';
      case 'eq5d5l':
        return 'Quality of Life Questionnaire (EQ-5D-5L)';
      default:
        return 'No questionnaire needed';
    }
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
            if (_isLoadingQuestionnaire) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (_errorMessage != null) ...[
              Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _loadNextQuestionnaire(),
                child: const Text('Retry'),
              ),
            ] else if (_nextQuestionnaireType == null) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'All questionnaires are up to date',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ] else if (!_isTodayFilled) ...[
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getQuestionnaireName(),
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (_questionnaireReason != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _questionnaireReason!,
                            style: TextStyle(
                              color: Colors.amber[700],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
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
                  Expanded(
                    child: Text(
                      '${_getQuestionnaireName()} - Completed',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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