import 'package:flutter/material.dart';

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
  final List<FoodItem> foodItems = [
    FoodItem(
      name: 'Vegetables (all types)',
      emoji: '🥬',
      examples: 'Cabbage, broccoli, carrots, beets, cauliflower, zucchini, spinach',
      unit: 'servings',
    ),
    FoodItem(
      name: 'Root vegetables',
      emoji: '🍠',
      examples: 'Potatoes with skin, carrots, parsnips, celery root',
      unit: 'servings',
    ),
    FoodItem(
      name: 'Whole grains',
      emoji: '🍞',
      examples: 'Oatmeal, buckwheat, pearl barley, brown rice, quinoa',
      unit: 'servings',
    ),
    FoodItem(
      name: 'Whole grain bread',
      emoji: '🍞',
      examples: 'Black bread, bran bread, whole grain bread',
      unit: 'slices',
    ),
    FoodItem(
      name: 'Nuts and seeds',
      emoji: '🌰',
      examples: 'Almonds, walnuts, hazelnuts, seeds, flax seeds, chia',
      unit: 'handfuls',
    ),
    FoodItem(
      name: 'Legumes',
      emoji: '🌱',
      examples: 'Beans (any), lentils, chickpeas, peas (including soups)',
      unit: 'servings',
    ),
    FoodItem(
      name: 'Fruits with skin',
      emoji: '🍏',
      examples: 'Apples, pears, plums, apricots (if skin eaten)',
      unit: 'pieces',
    ),
    FoodItem(
      name: 'Berries (any)',
      emoji: '🍓',
      examples: 'Raspberries, strawberries, blueberries, currants, blackberries',
      unit: 'handfuls',
    ),
    FoodItem(
      name: 'Soft fruits without skin',
      emoji: '🍌',
      examples: 'Bananas, melon, watermelon, mango',
      unit: 'pieces',
    ),
    FoodItem(
      name: 'Muesli and bran cereals',
      emoji: '🥣',
      examples: 'Sugar-free muesli, bran cereals, granola',
      unit: 'servings',
    ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('What did you consume today?', style: labelStyle, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ...foodItems.map((foodItem) {
          final int currentQuantity = widget.selectedItems[foodItem.name] ?? 0;
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
                      'Quantity (${foodItem.unit}):',
                      style: optionStyle,
                    ),
                    _buildCounter(
                      value: currentQuantity,
                      onChanged: (newQuantity) {
                        final newSelection = Map<String, int>.from(widget.selectedItems);
                        if (newQuantity == 0) {
                          newSelection.remove(foodItem.name);
                        } else {
                          newSelection[foodItem.name] = newQuantity;
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