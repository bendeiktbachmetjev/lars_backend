import 'package:flutter/material.dart';
import '../services/api_service.dart';

class Eq5d5lQuestionnaireScreen extends StatefulWidget {
  const Eq5d5lQuestionnaireScreen({super.key});

  @override
  State<Eq5d5lQuestionnaireScreen> createState() => _Eq5d5lQuestionnaireScreenState();
}

class _Eq5d5lQuestionnaireScreenState extends State<Eq5d5lQuestionnaireScreen> {
  int mobility = 0;
  int selfCare = 0;
  int usualActivities = 0;
  int painDiscomfort = 0;
  int anxietyDepression = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EQ-5D-5L Questionnaire'),
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
                    Text('MOBILITY', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        'I have no problems in walking about',
                        'I have slight problems in walking about',
                        'I have moderate problems in walking about',
                        'I have severe problems in walking about',
                        'I am unable to walk about',
                      ],
                      value: mobility,
                      onChanged: (v) => setState(() => mobility = v),
                    ),
                    const SizedBox(height: 24),
                    Text('SELF-CARE', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        'I have no problems washing or dressing myself',
                        'I have slight problems washing or dressing myself',
                        'I have moderate problems washing or dressing myself',
                        'I have severe problems washing or dressing myself',
                        'I am unable to wash or dress myself',
                      ],
                      value: selfCare,
                      onChanged: (v) => setState(() => selfCare = v),
                    ),
                    const SizedBox(height: 24),
                    Text('USUAL ACTIVITIES\n(e.g. work, study, housework, family or leisure activities)', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        'I have no problems doing my usual activities',
                        'I have slight problems doing my usual activities',
                        'I have moderate problems doing my usual activities',
                        'I have severe problems doing my usual activities',
                        'I am unable to do my usual activities',
                      ],
                      value: usualActivities,
                      onChanged: (v) => setState(() => usualActivities = v),
                    ),
                    const SizedBox(height: 24),
                    Text('PAIN / DISCOMFORT', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        'I have no pain or discomfort',
                        'I have slight pain or discomfort',
                        'I have moderate pain or discomfort',
                        'I have severe pain or discomfort',
                        'I have extreme pain or discomfort',
                      ],
                      value: painDiscomfort,
                      onChanged: (v) => setState(() => painDiscomfort = v),
                    ),
                    const SizedBox(height: 24),
                    Text('ANXIETY / DEPRESSION', style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        'I am not anxious or depressed',
                        'I am slightly anxious or depressed',
                        'I am moderately anxious or depressed',
                        'I am severely anxious or depressed',
                        'I am extremely anxious or depressed',
                      ],
                      value: anxietyDepression,
                      onChanged: (v) => setState(() => anxietyDepression = v),
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
                          final resp = await api.sendEq5d5l(
                            patientCode: code,
                            mobility: mobility,
                            selfCare: selfCare,
                            usualActivities: usualActivities,
                            painDiscomfort: painDiscomfort,
                            anxietyDepression: anxietyDepression,
                            rawData: {
                              'mobility': mobility,
                              'self_care': selfCare,
                              'usual_activities': usualActivities,
                              'pain_discomfort': painDiscomfort,
                              'anxiety_depression': anxietyDepression,
                            },
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

