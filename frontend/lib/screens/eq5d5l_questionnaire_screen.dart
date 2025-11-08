import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

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
  int healthVas = 50; // default middle value for VAS (0..100)

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
        title: Text(AppLocalizations.of(context)!.eq5d5lQuestionnaire),
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
                    Text(AppLocalizations.of(context)!.mobility, style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        AppLocalizations.of(context)!.noProblemsWalking,
                        AppLocalizations.of(context)!.slightProblemsWalking,
                        AppLocalizations.of(context)!.moderateProblemsWalking,
                        AppLocalizations.of(context)!.severeProblemsWalking,
                        AppLocalizations.of(context)!.unableToWalk,
                      ],
                      value: mobility,
                      onChanged: (v) => setState(() => mobility = v),
                    ),
                    const SizedBox(height: 24),
                    Text(AppLocalizations.of(context)!.selfCare, style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        AppLocalizations.of(context)!.noProblemsWashing,
                        AppLocalizations.of(context)!.slightProblemsWashing,
                        AppLocalizations.of(context)!.moderateProblemsWashing,
                        AppLocalizations.of(context)!.severeProblemsWashing,
                        AppLocalizations.of(context)!.unableToWash,
                      ],
                      value: selfCare,
                      onChanged: (v) => setState(() => selfCare = v),
                    ),
                    const SizedBox(height: 24),
                    Text(AppLocalizations.of(context)!.usualActivitiesDescription, style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        AppLocalizations.of(context)!.noProblemsUsualActivities,
                        AppLocalizations.of(context)!.slightProblemsUsualActivities,
                        AppLocalizations.of(context)!.moderateProblemsUsualActivities,
                        AppLocalizations.of(context)!.severeProblemsUsualActivities,
                        AppLocalizations.of(context)!.unableToDoUsualActivities,
                      ],
                      value: usualActivities,
                      onChanged: (v) => setState(() => usualActivities = v),
                    ),
                    const SizedBox(height: 24),
                    Text(AppLocalizations.of(context)!.painDiscomfort, style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        AppLocalizations.of(context)!.noPainDiscomfort,
                        AppLocalizations.of(context)!.slightPainDiscomfort,
                        AppLocalizations.of(context)!.moderatePainDiscomfort,
                        AppLocalizations.of(context)!.severePainDiscomfort,
                        AppLocalizations.of(context)!.extremePainDiscomfort,
                      ],
                      value: painDiscomfort,
                      onChanged: (v) => setState(() => painDiscomfort = v),
                    ),
                    const SizedBox(height: 24),
                    Text(AppLocalizations.of(context)!.anxietyDepression, style: labelStyle),
                    const SizedBox(height: 8),
                    _buildSelector(
                      options: [
                        AppLocalizations.of(context)!.notAnxiousDepressed,
                        AppLocalizations.of(context)!.slightlyAnxiousDepressed,
                        AppLocalizations.of(context)!.moderatelyAnxiousDepressed,
                        AppLocalizations.of(context)!.severelyAnxiousDepressed,
                        AppLocalizations.of(context)!.extremelyAnxiousDepressed,
                      ],
                      value: anxietyDepression,
                      onChanged: (v) => setState(() => anxietyDepression = v),
                    ),
                    const SizedBox(height: 24),
                    // Health VAS
                    Text(AppLocalizations.of(context)!.healthTodayTitle, style: labelStyle),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.healthTodayDescription,
                      style: const TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          // Vertical slider using rotation
                          Expanded(
                            child: SizedBox(
                              height: 220,
                              child: RotatedBox(
                                quarterTurns: -1,
                                child: Slider(
                                  value: healthVas.toDouble(),
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  label: healthVas.toString(),
                                  onChanged: (v) => setState(() => healthVas = v.round()),
                                  activeColor: Colors.black,
                                  inactiveColor: Colors.grey[300],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.yourHealthTodayIs,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: 88,
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[400]!),
                                ),
                                child: Text(
                                  healthVas.toString(),
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
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
                            SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSetPatientCode)),
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
                            healthVas: healthVas,
                            rawData: {
                              'mobility': mobility,
                              'self_care': selfCare,
                              'usual_activities': usualActivities,
                              'pain_discomfort': painDiscomfort,
                              'anxiety_depression': anxietyDepression,
                              'health_vas': healthVas,
                            },
                          );
                          if (resp.statusCode >= 200 && resp.statusCode < 300) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.submittedSuccessfully)),
                            );
                            Navigator.of(context).pop();
                          } else {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(AppLocalizations.of(context)!.submitFailed(resp.statusCode))),
                            );
                          }
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(AppLocalizations.of(context)!.error(e.toString()))),
                          );
                        }
                      },
                      child: Text(AppLocalizations.of(context)!.submit),
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

