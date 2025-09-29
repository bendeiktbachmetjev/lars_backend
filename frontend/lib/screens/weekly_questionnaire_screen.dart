import 'package:flutter/material.dart';
import '../services/api_service.dart';

class WeeklyQuestionnaireScreen extends StatefulWidget {
  const WeeklyQuestionnaireScreen({super.key});

  @override
  State<WeeklyQuestionnaireScreen> createState() => _WeeklyQuestionnaireScreenState();
}

class _WeeklyQuestionnaireScreenState extends State<WeeklyQuestionnaireScreen> {
  int flatusControl = 0;
  int liquidStoolLeakage = 0;
  int bowelFrequency = 0;
  int repeatBowelOpening = 0;
  int urgencyToToilet = 0;

  final TextStyle labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  final TextStyle optionStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  final Color selectedColor = Colors.black;
  final Color unselectedColor = Color(0xFFE0E0E0);

  Widget _buildSelector({
    required List<String> options,
    required int value,
    required void Function(int) onChanged,
  }) {
    return Column(
      children: List.generate(options.length, (i) {
        final bool selected = value == i;
        return Padding(
          padding: EdgeInsets.only(bottom: i != options.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: Container(
              width: double.infinity,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? selectedColor : unselectedColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected ? Colors.transparent : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  options[i],
                  style: optionStyle.copyWith(
                    color: selected ? Colors.white : Colors.black,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  int _calculateTotalScore() {
    // LARS scoring system based on the standard questionnaire
    final scores = [
      [0, 4, 7], // flatusControl: No never, Yes less than once per week, Yes at least once per week
      [0, 3, 3], // liquidStoolLeakage: No never, Yes less than once per week, Yes at least once per week
      [4, 2, 0, 5], // bowelFrequency: >7/day, 4-7/day, 1-3/day, <1/day
      [0, 9, 11], // repeatBowelOpening: No never, Yes less than once per week, Yes at least once per week
      [0, 11, 16], // urgencyToToilet: No never, Yes less than once per week, Yes at least once per week
    ];
    
    return scores[0][flatusControl] + 
           scores[1][liquidStoolLeakage] + 
           scores[2][bowelFrequency] + 
           scores[3][repeatBowelOpening] + 
           scores[4][urgencyToToilet];
  }

  @override
  Widget build(BuildContext context) {
    final totalScore = _calculateTotalScore();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('LARS Score Questionnaire'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 12),
                    Text('Do you ever have occasions when you cannot control your flatus (wind)?', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: ['No, never', 'Yes, less than once per week', 'Yes, at least once per week'],
                      value: flatusControl,
                      onChanged: (v) => setState(() => flatusControl = v),
                    ),
                    const SizedBox(height: 24),
                    Text('Do you ever have any accidental leakage of liquid stool?', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: ['No, never', 'Yes, less than once per week', 'Yes, at least once per week'],
                      value: liquidStoolLeakage,
                      onChanged: (v) => setState(() => liquidStoolLeakage = v),
                    ),
                    const SizedBox(height: 24),
                    Text('How often do you open your bowels?', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: ['More than 7 times per day (24 hours)', '4-7 times per day (24 hours)', '1-3 times per day (24 hours)', 'Less than once per day (24 hours)'],
                      value: bowelFrequency,
                      onChanged: (v) => setState(() => bowelFrequency = v),
                    ),
                    const SizedBox(height: 24),
                    Text('Do you ever have to open your bowels again within one hour of the last bowel opening?', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: ['No, never', 'Yes, less than once per week', 'Yes, at least once per week'],
                      value: repeatBowelOpening,
                      onChanged: (v) => setState(() => repeatBowelOpening = v),
                    ),
                    const SizedBox(height: 24),
                    Text('Do you ever have such a strong urge to open your bowels that you have to rush to the toilet?', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: ['No, never', 'Yes, less than once per week', 'Yes, at least once per week'],
                      value: urgencyToToilet,
                      onChanged: (v) => setState(() => urgencyToToilet = v),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Score:', style: labelStyle.copyWith(fontSize: 18)),
                          Text(
                            totalScore.toString(),
                            style: labelStyle.copyWith(
                              fontSize: 24,
                              color: totalScore <= 20 ? Colors.green : totalScore <= 29 ? Colors.orange : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF3A8DFF), Color(0xFF8F5CFF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final api = ApiService();
                        final code = await api.getPatientCode();
                        if (code == null || code.isEmpty) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please set your patient code in Profile')),
                          );
                          return;
                        }

                        try {
                          final resp = await api.sendWeekly(
                            patientCode: code,
                            flatusControl: flatusControl,
                            liquidStoolLeakage: liquidStoolLeakage,
                            bowelFrequency: bowelFrequency,
                            repeatBowelOpening: repeatBowelOpening,
                            urgencyToToilet: urgencyToToilet,
                            rawData: {"total_score": totalScore},
                          );
                          if (resp.statusCode >= 200 && resp.statusCode < 300) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Submitted successfully')),
                            );
                            Navigator.of(context).pop();
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Submit failed: ${resp.statusCode}')),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 