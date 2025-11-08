import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class FoodItem {
  final String name;
  final String emoji;
  final String examples;
  final String unit;
  final int maxQuantity;

  FoodItem({
    required this.name,
    required this.emoji,
    required this.examples,
    required this.unit,
    this.maxQuantity = 10,
  });
}

class FoodConsumptionSelector extends StatefulWidget {
  final Map<String, int> selectedItems;
  final void Function(Map<String, int>) onChanged;

  const FoodConsumptionSelector({
    super.key,
    required this.selectedItems,
    required this.onChanged,
  });

  @override
  State<FoodConsumptionSelector> createState() => _FoodConsumptionSelectorState();
}

class _FoodConsumptionSelectorState extends State<FoodConsumptionSelector> {
  List<FoodItem> _getFoodItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      FoodItem(
        name: l10n.foodVegetablesAllTypes,
        emoji: '🥬',
        examples: l10n.foodVegetablesExamples,
        unit: l10n.unitServings,
      ),
      FoodItem(
        name: l10n.foodRootVegetables,
        emoji: '🍠',
        examples: l10n.foodRootVegetablesExamples,
        unit: l10n.unitServings,
      ),
      FoodItem(
        name: l10n.foodWholeGrains,
        emoji: '🍞',
        examples: l10n.foodWholeGrainsExamples,
        unit: l10n.unitServings,
      ),
      FoodItem(
        name: l10n.foodWholeGrainBread,
        emoji: '🍞',
        examples: l10n.foodWholeGrainBreadExamples,
        unit: l10n.unitSlices,
      ),
      FoodItem(
        name: l10n.foodNutsAndSeeds,
        emoji: '🌰',
        examples: l10n.foodNutsAndSeedsExamples,
        unit: l10n.unitHandfuls,
      ),
      FoodItem(
        name: l10n.foodLegumes,
        emoji: '🌱',
        examples: l10n.foodLegumesExamples,
        unit: l10n.unitServings,
      ),
      FoodItem(
        name: l10n.foodFruitsWithSkin,
        emoji: '🍏',
        examples: l10n.foodFruitsWithSkinExamples,
        unit: l10n.unitPieces,
      ),
      FoodItem(
        name: l10n.foodBerriesAny,
        emoji: '🍓',
        examples: l10n.foodBerriesExamples,
        unit: l10n.unitHandfuls,
      ),
      FoodItem(
        name: l10n.foodSoftFruitsWithoutSkin,
        emoji: '🍌',
        examples: l10n.foodSoftFruitsExamples,
        unit: l10n.unitPieces,
      ),
      FoodItem(
        name: l10n.foodMuesliAndBranCereals,
        emoji: '🥣',
        examples: l10n.foodMuesliExamples,
        unit: l10n.unitServings,
      ),
    ];
  }
  
  // Internal keys for storing selections (language-independent)
  static const List<String> _foodItemKeys = [
    'vegetables_all_types',
    'root_vegetables',
    'whole_grains',
    'whole_grain_bread',
    'nuts_and_seeds',
    'legumes',
    'fruits_with_skin',
    'berries_any',
    'soft_fruits_without_skin',
    'muesli_and_bran_cereals',
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
    final foodItems = _getFoodItems(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(AppLocalizations.of(context)!.whatDidYouConsumeToday, style: labelStyle, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ...foodItems.asMap().entries.map((entry) {
          final index = entry.key;
          final foodItem = entry.value;
          final String itemKey = _foodItemKeys[index];
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
                    Text(foodItem.emoji, style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            foodItem.name,
                            style: labelStyle.copyWith(fontSize: 18),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            foodItem.examples,
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
                      AppLocalizations.of(context)!.quantity(foodItem.unit),
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
                      max: foodItem.maxQuantity,
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