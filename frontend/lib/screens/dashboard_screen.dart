import 'package:flutter/material.dart';
import 'daily_questionnaire_screen.dart';
import 'weekly_questionnaire_screen.dart';
import 'monthly_questionnaire_screen.dart';
import 'eq5d5l_questionnaire_screen.dart';
import '../widgets/lars_line_chart.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

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
        // Error message will be localized when displayed
        setState(() {
          _nextQuestionnaireType = null;
          _isTodayFilled = false;
          _isLoadingQuestionnaire = false;
          _errorMessage = 'patient_code_not_set';
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
          _errorMessage = 'failed_to_load';
        });
      }
      } catch (e) {
        setState(() {
          _nextQuestionnaireType = null;
          _isTodayFilled = false;
          _isLoadingQuestionnaire = false;
          _errorMessage = 'error_prefix:${e.toString()}';
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

  String _getQuestionnaireName(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (_nextQuestionnaireType) {
      case 'daily':
        return l10n.dailyQuestionnaire;
      case 'weekly':
        return l10n.weeklyQuestionnaire;
      case 'monthly':
        return l10n.monthlyQuestionnaire;
      case 'eq5d5l':
        return l10n.qualityOfLifeQuestionnaire;
      default:
        return l10n.noQuestionnaireNeeded;
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
            Text(
              AppLocalizations.of(context)!.todaysQuestionnaire,
              style: const TextStyle(
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
                      _errorMessage == 'patient_code_not_set'
                          ? AppLocalizations.of(context)!.pleaseSetPatientCode
                          : _errorMessage == 'failed_to_load'
                              ? AppLocalizations.of(context)!.failedToLoadQuestionnaireInfo
                              : _errorMessage!.startsWith('error_prefix:')
                                  ? AppLocalizations.of(context)!.error(_errorMessage!.substring('error_prefix:'.length))
                                  : _errorMessage!,
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
                child: Text(AppLocalizations.of(context)!.retry),
              ),
            ] else if (_nextQuestionnaireType == null) ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.allQuestionnairesUpToDate,
                    style: const TextStyle(
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
                          _getQuestionnaireName(context),
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
                  child: Text(AppLocalizations.of(context)!.fillItNow),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${_getQuestionnaireName(context)} - Completed',
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

  String _getStatisticsText(String period, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (_larsData == null || _larsData!.isEmpty) {
      return l10n.completeWeeklyQuestionnairesToSeeStatistics;
    }

    final scores = _larsData!
        .where((item) => item['score'] != null)
        .map((item) => (item['score'] as num).toDouble())
        .toList();

    if (scores.length < 2) {
      return l10n.completeMoreWeeklyQuestionnaires;
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
        Text(
          AppLocalizations.of(context)!.statistics,
          style: const TextStyle(
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
              Builder(
                builder: (context) {
                  final statsText = _getStatisticsText(_selectedPeriod, context);
                  final hasEnoughData = _larsData != null && _larsData!.isNotEmpty && _larsData!.where((item) => item['score'] != null).length >= 2;
                  return Icon(
                    hasEnoughData
                        ? (statsText.contains('improved') 
                            ? Icons.trending_up 
                            : statsText.contains('stable')
                                ? Icons.trending_flat
                                : Icons.trending_down)
                        : Icons.info_outline,
                    color: hasEnoughData
                        ? (statsText.contains('improved') 
                            ? Colors.green 
                            : statsText.contains('stable')
                                ? Colors.orange
                                : Colors.red)
                        : Colors.grey,
                    size: 28,
                  );
                },
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
                        _getStatisticsText(_selectedPeriod, context),
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