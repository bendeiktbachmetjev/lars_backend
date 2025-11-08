import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

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
  List<FlSpot> _data = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ApiService();
      final patientCode = await api.getPatientCode();
      
      if (patientCode == null || patientCode.isEmpty) {
        setState(() {
          _isLoading = false;
          _data = [];
          _errorMessage = 'No patient code set'; // Will be localized when displayed
        });
        return;
      }

      final periodStr = _selectedPeriod == TimePeriod.weekly 
          ? 'weekly' 
          : _selectedPeriod == TimePeriod.monthly 
              ? 'monthly' 
              : 'yearly';
      
      final response = await api.getLarsData(
        patientCode: patientCode,
        period: periodStr,
      );

      if (response['status'] == 'ok' && response['data'] != null) {
        final List<dynamic> dataList = response['data'];
        final List<FlSpot> spots = [];
        
        for (var item in dataList) {
          final index = item['index'] as int;
          final score = item['score'];
          if (score != null) {
            spots.add(FlSpot(index.toDouble(), (score as num).toDouble()));
          }
        }
        
        setState(() {
          _data = spots;
          _isLoading = false;
          _errorMessage = null; // Clear any previous error
        });
      } else {
        setState(() {
          _data = [];
          _isLoading = false;
          _errorMessage = null; // No error if status is ok but no data
        });
      }
    } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to fetch LARS data:${e.toString()}'; // Will be localized when displayed
          _data = [];
        });
    }
  }

  @override
  void didUpdateWidget(LarsLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload data if period changed externally
    if (oldWidget.onPeriodChanged != widget.onPeriodChanged) {
      _loadData();
    }
  }

  String _getXAxisLabel(double value, TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        // Show all 5 weeks
        return 'W${value.toInt()}';
      case TimePeriod.monthly:
        // Show all 6 months
        return 'M${value.toInt()}';
      case TimePeriod.yearly:
        return 'Y${value.toInt()}';
    }
    return '';
  }

  double _getInterval(TimePeriod period) {
    switch (period) {
      case TimePeriod.weekly:
        return 1.0; // Show every week for 5 weeks
      case TimePeriod.monthly:
        return 1.0; // Show every month for 6 months
      case TimePeriod.yearly:
        return 1.0;
    }
  }

  int _getMaxX(TimePeriod period) {
    if (_data.isEmpty) {
      // Default max X if no data
      switch (period) {
        case TimePeriod.weekly:
          return 5;
        case TimePeriod.monthly:
          return 6;
        case TimePeriod.yearly:
          return 5;
      }
    }
    if (_data.length == 1) {
      // For single point, show at least to index 2 for better visualization
      return _data.first.x.toInt() + 1;
    }
    // Use actual data max X, with some padding
    final maxXFromData = _data.map((spot) => spot.x).reduce((a, b) => a > b ? a : b);
    return (maxXFromData + 1).toInt();
  }

  double _getMaxY() {
    if (_data.isEmpty) return 40.0;
    if (_data.length == 1) {
      // For single point, set reasonable range
      final score = _data.first.y;
      return (score + 10).clamp(20.0, 50.0);
    }
    final maxYFromData = _data.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
    // Add some padding (20% or at least 5 points)
    final padding = (maxYFromData * 0.2).clamp(5.0, 10.0);
    return (maxYFromData + padding).clamp(20.0, 50.0);
  }

  @override
  Widget build(BuildContext context) {
    final maxX = _getMaxX(_selectedPeriod);
    final interval = _getInterval(_selectedPeriod);
    final maxY = _getMaxY();
    
    return Column(
      children: [
        // Period selection buttons
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPeriodButton(TimePeriod.weekly, AppLocalizations.of(context)!.weekly),
              const SizedBox(width: 8),
              _buildPeriodButton(TimePeriod.monthly, AppLocalizations.of(context)!.monthly),
              const SizedBox(width: 8),
              _buildPeriodButton(TimePeriod.yearly, AppLocalizations.of(context)!.yearly),
            ],
          ),
        ),
        // Chart
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            height: 180,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _data.isEmpty && _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage == 'No patient code set'
                                  ? AppLocalizations.of(context)!.noPatientCodeSet
                                  : _errorMessage!.startsWith('Failed to fetch LARS data:')
                                      ? AppLocalizations.of(context)!.failedToFetchLarsData(_errorMessage!.substring('Failed to fetch LARS data:'.length).trim())
                                      : _errorMessage!,
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : _data.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.noDataAvailableYet,
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                    : LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true, drawVerticalLine: false),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 32,
                                interval: maxY > 20 ? 10 : 5,
                              ),
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
                          minX: _data.isEmpty 
                              ? 1 
                              : (_data.length == 1 
                                  ? (_data.first.x - 0.5).clamp(0.5, double.infinity)
                                  : (_data.map((s) => s.x).reduce((a, b) => a < b ? a : b) - 0.5).clamp(0.5, double.infinity)),
                          maxX: maxX.toDouble(),
                          minY: 0,
                          maxY: maxY,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _data,
                              isCurved: _data.length > 1, // Only curve if more than one point
                              color: Colors.black,
                              barWidth: 3,
                              dotData: FlDotData(show: _data.length <= 10), // Show dots if few data points (including single point)
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
        _loadData(); // Reload data when period changes
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