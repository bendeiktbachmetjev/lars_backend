import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class BristolScaleSelector extends StatelessWidget {
  final int selectedValue;
  final Function(int) onChanged;

  const BristolScaleSelector({
    super.key,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.stoolConsistency,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        
        // Grid for Bristol Scale 1-6 (2 columns x 3 rows)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2, // Slightly wider for better balance
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            final scaleValue = index + 1;
            final isSelected = selectedValue == scaleValue;
            
            return _buildBristolScaleItem(
              scaleValue: scaleValue,
              isSelected: isSelected,
              onTap: () => onChanged(scaleValue),
            );
          },
        ),
        
        const SizedBox(height: 12),
        
        // Bristol Scale 7 (full width)
        _buildBristolScaleItem(
          scaleValue: 7,
          isSelected: selectedValue == 7,
          onTap: () => onChanged(7),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildBristolScaleItem({
    required int scaleValue,
    required bool isSelected,
    required VoidCallback onTap,
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: 120, // Fixed height for all items
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
            ? Border.all(color: Colors.black, width: 3)
            : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bristol Scale image - much larger now
            Container(
              width: isFullWidth ? 260 : 140, // Much larger for Bristol 1-6
              height: isFullWidth ? 70 : 90,  // Taller for better proportions
              child: Image.asset(
                'assets/images/bristol_scale/bristol_$scaleValue.png',
                fit: BoxFit.contain, // Changed to contain for better display
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image not found
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image,
                      color: Colors.grey[600],
                      size: isFullWidth ? 32 : 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              scaleValue.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.black : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 