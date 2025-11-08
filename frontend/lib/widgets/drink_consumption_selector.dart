import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class DrinkItem {
  final String name;
  final String emoji;
  final String examples;
  final String unit;
  final int maxQuantity;

  DrinkItem({
    required this.name,
    required this.emoji,
    required this.examples,
    required this.unit,
    this.maxQuantity = 10,
  });
}

class DrinkConsumptionSelector extends StatefulWidget {
  final Map<String, int> selectedItems;
  final void Function(Map<String, int>) onChanged;

  const DrinkConsumptionSelector({
    super.key,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  State<DrinkConsumptionSelector> createState() => _DrinkConsumptionSelectorState();
}

class _DrinkConsumptionSelectorState extends State<DrinkConsumptionSelector> {
  List<DrinkItem> _getDrinkItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      DrinkItem(
        name: l10n.drinkWater,
        emoji: '💧',
        examples: l10n.drinkWaterExamples,
        unit: l10n.unitGlasses,
      ),
      DrinkItem(
        name: l10n.drinkCoffee,
        emoji: '☕',
        examples: l10n.drinkCoffeeExamples,
        unit: l10n.unitCups,
      ),
      DrinkItem(
        name: l10n.drinkTea,
        emoji: '🫖',
        examples: l10n.drinkTeaExamples,
        unit: l10n.unitCups,
      ),
      DrinkItem(
        name: l10n.drinkAlcohol,
        emoji: '🍷',
        examples: l10n.drinkAlcoholExamples,
        unit: l10n.unitDrinks,
      ),
      DrinkItem(
        name: l10n.drinkCarbonatedDrinks,
        emoji: '🥤',
        examples: l10n.drinkCarbonatedExamples,
        unit: l10n.unitCans,
      ),
      DrinkItem(
        name: l10n.drinkJuices,
        emoji: '🧃',
        examples: l10n.drinkJuicesExamples,
        unit: l10n.unitGlasses,
      ),
      DrinkItem(
        name: l10n.drinkDairyDrinks,
        emoji: '🥛',
        examples: l10n.drinkDairyExamples,
        unit: l10n.unitGlasses,
      ),
      DrinkItem(
        name: l10n.drinkEnergyDrinks,
        emoji: '⚡',
        examples: l10n.drinkEnergyExamples,
        unit: l10n.unitCans,
      ),
    ];
  }
  
  // Internal keys for storing selections (language-independent)
  static const List<String> _drinkItemKeys = [
    'water',
    'coffee',
    'tea',
    'alcohol',
    'carbonated_drinks',
    'juices',
    'dairy_drinks',
    'energy_drinks',
  ];

  final TextStyle labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  final TextStyle optionStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  final Color selectedColor = Colors.black;
  final Color unselectedColor = Color(0xFFE0E0E0);

  Widget _buildCounter({
    required int value,
    required void Function(int) onChanged,
    int min = 0,
    int max = 10,
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

  @override
  Widget build(BuildContext context) {
    final drinkItems = _getDrinkItems(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context)!.whatDidYouDrinkToday, style: labelStyle, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ...drinkItems.asMap().entries.map((entry) {
          final index = entry.key;
          final drinkItem = entry.value;
          final String itemKey = _drinkItemKeys[index];
          final int currentQuantity = widget.selectedItems[itemKey] ?? 0;
          final bool isSelected = currentQuantity > 0;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              border: Border.all(
                color: isSelected ? selectedColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(drinkItem.emoji, style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            drinkItem.name,
                            style: labelStyle.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            drinkItem.examples,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.quantity(drinkItem.unit),
                      style: optionStyle,
                    ),
                    _buildCounter(
                      value: currentQuantity,
                      onChanged: (newQuantity) {
                        final newSelection = Map<String, int>.from(widget.selectedItems);
                        if (newQuantity == 0) {
                          newSelection.remove(itemKey);
                        } else {
                          newSelection[itemKey] = newQuantity;
                        }
                        widget.onChanged(newSelection);
                      },
                      max: drinkItem.maxQuantity,
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
} 