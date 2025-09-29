import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'dart:math';

/// Enum for different time periods
enum TimePeriod { weekly, monthly, yearly }

/// Widget that displays a LARS score line chart with period selection.
class LarsLineChart extends StatefulWidget {
  final Function(TimePeriod)? onPeriodChanged;
  
  const LarsLineChart({super.key, this.onPeriodChanged});

  @override
  State<LarsLineChart> createState() => _LarsLineChartState();
}

class _LarsLineChartState extends State<LarsLineChart> {
  TimePeriod _selectedPeriod = TimePeriod.weekly;

  List<FlSpot> _generateFakeData(TimePeriod period) {
    final random = Random(42);
    int dataPoints;
    double interval;
    String xAxisLabel;
    
    switch (period) {
      case TimePeriod.weekly:
        dataPoints = 20;
        interval = 4.0;
        xAxisLabel = 'W';
        break;
      case TimePeriod.monthly:
        dataPoints = 12;
        interval = 1.0;
        xAxisLabel = 'M';
        break;
      case TimePeriod.yearly:
        dataPoints = 5;
        interval = 1.0;
        xAxisLabel = 'Y';
        break;
    }
    
    return List.generate(dataPoints, (i) => FlSpot(i.toDouble() + 1, 20 + random.nextInt(21).toDouble()));
  }

  String _getXAxisLabel(double value, TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        if (value % 4 == 0 || value == 1 || value == 20) {
          return 'W${value.toInt()}';
        }
        break;
      case TimePeriod.monthly:
        if (value % 2 == 0 || value == 1 || value == 12) {
          return 'M${value.toInt()}';
        }
        break;
      case TimePeriod.yearly:
        return 'Y${value.toInt()}';
    }
    return '';
  }

  double _getInterval(TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return 4.0;
      case TimePeriod.monthly:
        return 2.0;
      case TimePeriod.yearly:
        return 1.0;
    }
  }

  int _getMaxX(TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return 20;
      case TimePeriod.monthly:
        return 12;
      case TimePeriod.yearly:
        return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _generateFakeData(_selectedPeriod);
    final maxX = _getMaxX(_selectedPeriod);
    final interval = _getInterval(_selectedPeriod);
    
    return Column(
      children: [
        // Period selection buttons
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPeriodButton(TimePeriod.weekly, 'Weekly'),
              const SizedBox(width: 8),
              _buildPeriodButton(TimePeriod.monthly, 'Monthly'),
              const SizedBox(width: 8),
              _buildPeriodButton(TimePeriod.yearly, 'Yearly'),
            ],
          ),
        ),
        // Chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, reservedSize: 32),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        final label = _getXAxisLabel(value, _selectedPeriod);
                        if (label.isNotEmpty) {
                          return Text(label, style: const TextStyle(fontSize: 12));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: maxX.toDouble(),
                minY: 0,
                maxY: 40,
                lineBarsData: [
                  LineChartBarData(
                    spots: data,
                    isCurved: true,
                    color: Colors.black,
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodButton(TimePeriod period, String label) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
        widget.onPeriodChanged?.call(period);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
} 