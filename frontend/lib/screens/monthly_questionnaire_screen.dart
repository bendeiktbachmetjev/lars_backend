import 'package:flutter/material.dart';

class MonthlyQuestionnaireScreen extends StatefulWidget {
  const MonthlyQuestionnaireScreen({super.key});

  @override
  State<MonthlyQuestionnaireScreen> createState() => _MonthlyQuestionnaireScreenState();
}

class _MonthlyQuestionnaireScreenState extends State<MonthlyQuestionnaireScreen> {
  double avoidTravel = 1;
  double avoidSocial = 1;
  double embarrassed = 1;
  double worryNotice = 1;
  double depressed = 1;
  double control = 0;
  double satisfaction = 0;

  final TextStyle labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  final Color activeColor = Colors.black;

  Widget _buildLikertSlider({
    required String label,
    required double value,
    required int min,
    required int max,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        Row(
          children: [
            Text('$min', style: const TextStyle(fontSize: 14)),
            Expanded(
              child: Slider(
                value: value,
                min: min.toDouble(),
                max: max.toDouble(),
                divisions: max - min,
                label: value.round().toString(),
                onChanged: onChanged,
                activeColor: activeColor,
                thumbColor: activeColor,
              ),
            ),
            Text('$max', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Quality of Life '),
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
                    _buildLikertSlider(
                      label: 'I avoid traveling due to bowel problems',
                      value: avoidTravel,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => avoidTravel = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: 'I avoid social activities',
                      value: avoidSocial,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => avoidSocial = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: 'I feel embarrassed by my condition',
                      value: embarrassed,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => embarrassed = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: 'I worry others will notice my symptoms',
                      value: worryNotice,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => worryNotice = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: 'I feel depressed because of bowel function',
                      value: depressed,
                      min: 1,
                      max: 4,
                      onChanged: (v) => setState(() => depressed = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: 'I feel in control of my bowel symptoms',
                      value: control,
                      min: 0,
                      max: 10,
                      onChanged: (v) => setState(() => control = v),
                    ),
                    const SizedBox(height: 24),
                    _buildLikertSlider(
                      label: 'Overall satisfaction with bowel function',
                      value: satisfaction,
                      min: 0,
                      max: 10,
                      onChanged: (v) => setState(() => satisfaction = v),
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
                      onPressed: () {
                        // TODO: Implement submit logic
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