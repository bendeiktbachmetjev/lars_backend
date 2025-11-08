import 'package:flutter/material.dart';
import '../widgets/bristol_scale_selector.dart';
import '../services/api_service.dart';
import '../widgets/food_consumption_selector.dart';
import '../widgets/drink_consumption_selector.dart';
import '../l10n/app_localizations.dart';

class DailyQuestionnaireScreen extends StatefulWidget {
  const DailyQuestionnaireScreen({super.key});

  @override
  State<DailyQuestionnaireScreen> createState() => _DailyQuestionnaireScreenState();
}

class _DailyQuestionnaireScreenState extends State<DailyQuestionnaireScreen> {
  int stoolCount = 0;
  int padsUsed = 0;
  String urgency = 'No';
  String nightStools = 'No';
  String leakage = 'None';
  String incompleteEvac = 'No';
  double bloating = 0;
  double impactScore = 0;
  double activityInterfere = 0;
  int bristolScale = 1;
  
  // Variables for food and drink consumption
  Map<String, int> consumedFoodItems = {};
  Map<String, int> consumedDrinkItems = {};

  final TextStyle labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  final TextStyle optionStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  final Color selectedColor = Colors.black;
  final Color unselectedColor = Color(0xFFE0E0E0);

  Widget _buildCounter({
    required int value,
    required void Function(int) onChanged,
    int min = 0,
    int max = 100,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: Colors.black,
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Container(
          width: 36,
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: optionStyle,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: Colors.black,
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }

  Widget _buildYesNo(BuildContext context, {required String value, required void Function(String) onChanged}) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOption(l10n.yes, value == 'Yes', () => onChanged('Yes')),
        const SizedBox(width: 10),
        _buildOption(l10n.no, value == 'No', () => onChanged('No')),
      ],
    );
  }

  Widget _buildOption(String text, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 56, minHeight: 44),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? selectedColor : unselectedColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: optionStyle.copyWith(color: selected ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget _buildSelector<T>({
    required List<T> options,
    required T value,
    required void Function(T) onChanged,
    double spacing = 10,
    double height = 44,
    double minWidth = 56,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((opt) {
        final bool selected = opt == value;
        return Padding(
          padding: EdgeInsets.only(right: opt != options.last ? spacing : 0),
          child: GestureDetector(
            onTap: () => onChanged(opt),
            child: Container(
              constraints: BoxConstraints(minWidth: minWidth, minHeight: height),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? selectedColor : unselectedColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                opt.toString(),
                style: optionStyle.copyWith(color: selected ? Colors.white : Colors.black),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required void Function(double) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(label, style: labelStyle, textAlign: TextAlign.center),
        Row(
          children: [
            const Text('0', style: TextStyle(fontSize: 14)),
            Expanded(
              child: Slider(
                value: value,
                min: 0,
                max: 10,
                divisions: 10,
                label: value.round().toString(),
                onChanged: onChanged,
              ),
            ),
            const Text('10', style: TextStyle(fontSize: 14)),
          ],
        ),
      ],
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dailySymptoms),
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
                    // Stool/day & Pads Used
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(minHeight: 80),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                            ),
                            child: Column(
                              children: [
                                Text(AppLocalizations.of(context)!.stoolPerDay, style: labelStyle),
                                const SizedBox(height: 8),
                                _buildCounter(
                                  value: stoolCount,
                                  onChanged: (v) => setState(() => stoolCount = v),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(minHeight: 80),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                            ),
                            child: Column(
                              children: [
                                Text(AppLocalizations.of(context)!.padsUsed, style: labelStyle),
                                const SizedBox(height: 8),
                                _buildCounter(
                                  value: padsUsed,
                                  onChanged: (v) => setState(() => padsUsed = v),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Urgent & Night stools
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(minHeight: 80),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.urgent, style: labelStyle),
                                const SizedBox(height: 8),
                                _buildYesNo(
                                  context,
                                  value: urgency,
                                  onChanged: (v) => setState(() => urgency = v),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(minHeight: 80),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.nightStools, style: labelStyle),
                                const SizedBox(height: 8),
                                _buildYesNo(
                                  context,
                                  value: nightStools,
                                  onChanged: (v) => setState(() => nightStools = v),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stool leakage & Incomplete evacuation (две секции в ряд)
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(minHeight: 140),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                            ),
                            child: Column(
                              children: [
                                Text(AppLocalizations.of(context)!.stoolLeakage, style: labelStyle),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildOption(AppLocalizations.of(context)!.none, leakage == 'None', () => setState(() => leakage = 'None')),
                                    const SizedBox(width: 10),
                                    _buildOption(AppLocalizations.of(context)!.liquid, leakage == 'Liquid', () => setState(() => leakage = 'Liquid')),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildOption(AppLocalizations.of(context)!.solid, leakage == 'Solid', () => setState(() => leakage = 'Solid')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.all(12),
                            constraints: const BoxConstraints(minHeight: 140),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              border: Border.all(color: Colors.grey[300]!, width: 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(child: Text(AppLocalizations.of(context)!.incompleteEvacuation, style: labelStyle)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildOption(AppLocalizations.of(context)!.yes, incompleteEvac == 'Yes', () => setState(() => incompleteEvac = 'Yes')),
                                    const SizedBox(width: 10),
                                    _buildOption(AppLocalizations.of(context)!.no, incompleteEvac == 'No', () => setState(() => incompleteEvac = 'No')),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Bloating
                    _buildSlider(
                      label: AppLocalizations.of(context)!.bloating,
                      value: bloating,
                      onChanged: (v) => setState(() => bloating = v),
                    ),
                    const SizedBox(height: 20),
                    // Impact on life
                    _buildSlider(
                      label: AppLocalizations.of(context)!.impactOnLife,
                      value: impactScore,
                      onChanged: (v) => setState(() => impactScore = v),
                    ),
                    const SizedBox(height: 20),
                    // Drink consumption
                    DrinkConsumptionSelector(
                      selectedItems: consumedDrinkItems,
                      onChanged: (items) => setState(() => consumedDrinkItems = items),
                    ),
                    const SizedBox(height: 20),
                    // Food consumption
                    FoodConsumptionSelector(
                      selectedItems: consumedFoodItems,
                      onChanged: (items) => setState(() => consumedFoodItems = items),
                    ),
                    const SizedBox(height: 20),
                    // Bristol stool type
                    BristolScaleSelector(
                      selectedValue: bristolScale,
                      onChanged: (v) => setState(() => bristolScale = v),
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

                        final raw = {
                          'stool_count': stoolCount,
                          'pads_used': padsUsed,
                          'urgency': urgency,
                          'night_stools': nightStools,
                          'leakage': leakage,
                          'incomplete_evacuation': incompleteEvac,
                          'bloating': bloating,
                          'impact_score': impactScore,
                          'activity_interfere': activityInterfere,
                        };

                        try {
                          final resp = await api.sendDaily(
                            patientCode: code,
                            bristolScale: bristolScale,
                            foodConsumption: consumedFoodItems,
                            drinkConsumption: consumedDrinkItems,
                            rawData: raw,
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