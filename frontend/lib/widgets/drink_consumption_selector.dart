import 'package:flutter/material.dart';

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
  final List<DrinkItem> drinkItems = [
    DrinkItem(
      name: 'Water',
      emoji: '💧',
      examples: 'Plain water, mineral water, filtered water',
      unit: 'glasses',
    ),
    DrinkItem(
      name: 'Coffee',
      emoji: '☕',
      examples: 'Espresso, cappuccino, americano, latte',
      unit: 'cups',
    ),
    DrinkItem(
      name: 'Tea',
      emoji: '🫖',
      examples: 'Black tea, green tea, herbal tea, chamomile',
      unit: 'cups',
    ),
    DrinkItem(
      name: 'Alcohol',
      emoji: '🍷',
      examples: 'Beer, wine, spirits, cocktails',
      unit: 'drinks',
    ),
    DrinkItem(
      name: 'Carbonated drinks',
      emoji: '🥤',
      examples: 'Cola, sprite, fanta, sparkling water',
      unit: 'cans',
    ),
    DrinkItem(
      name: 'Juices',
      emoji: '🧃',
      examples: 'Orange juice, apple juice, grape juice, smoothies',
      unit: 'glasses',
    ),
    DrinkItem(
      name: 'Dairy drinks',
      emoji: '🥛',
      examples: 'Milk, kefir, yogurt drinks, milkshakes',
      unit: 'glasses',
    ),
    DrinkItem(
      name: 'Energy drinks',
      emoji: '⚡',
      examples: 'Red Bull, Monster, energy shots',
      unit: 'cans',
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
        Text('What did you drink today?', style: labelStyle, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        ...drinkItems.map((drinkItem) {
          final int currentQuantity = widget.selectedItems[drinkItem.name] ?? 0;
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
                      'Quantity (${drinkItem.unit}):',
                      style: optionStyle,
                    ),
                    _buildCounter(
                      value: currentQuantity,
                      onChanged: (newQuantity) {
                        final newSelection = Map<String, int>.from(widget.selectedItems);
                        if (newQuantity == 0) {
                          newSelection.remove(drinkItem.name);
                        } else {
                          newSelection[drinkItem.name] = newQuantity;
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