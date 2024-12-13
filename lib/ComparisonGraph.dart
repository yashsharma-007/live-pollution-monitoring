import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'SensorData.dart';

class ComparisonGraph extends StatelessWidget {
  final List<SensorData> data;

  ComparisonGraph({required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparison Graph'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: buildLegend(),
          ),
          Expanded(
            child: buildGraph(data),
          ),
        ],
      ),
    );
  }

  // Create an enhanced legend to identify different lines
  Widget buildLegend() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          buildLegendItem(Colors.red, 'AB3 Backside'),
          buildLegendItem(Colors.green, 'MGR Statue'),
          buildLegendItem(Colors.blue, 'A Block'),
        ],
      ),
    );
  }

  // Helper function to build a legend item with rounded markers
  Widget buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // Create line chart with average MQ135 values
  Widget buildGraph(List<SensorData> data) {
    // Filter data by locations
    List<SensorData> ab3Data = filterDataByLocation(data, 'AB3 Backside');
    List<SensorData> mgrData = filterDataByLocation(data, 'MGR Statue');
    List<SensorData> aBlockData = filterDataByLocation(data, 'A block');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          minY: 340, // Lower limit of Y-axis
          maxY: 480, // Upper limit of Y-axis
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  switch (value.toInt()) {
                    case 0:
                      return const Text('8am');
                    case 1:
                      return const Text('10am');
                    case 2:
                      return const Text('12pm');
                    case 3:
                      return const Text('3pm');
                    case 4:
                      return const Text('5pm');
                    case 5:
                      return const Text('7pm');
                    case 6:
                      return const Text('9pm');
                    default:
                      return const Text('');
                  }
                },
                interval: 1,
                reservedSize: 40,
              ),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false, // Removed top X-axis labels
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 20,
                reservedSize: 50,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.black, width: 1),
          ),
          lineBarsData: [
            // Graph for AB3 Backside (now using red)
            LineChartBarData(
              spots: generateGraphData(ab3Data),
              isCurved: true,
              color: Colors.red,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
            // Graph for MGR Statue (using green)
            LineChartBarData(
              spots: generateGraphData(mgrData),
              isCurved: true,
              color: Colors.green,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
            // Graph for A Block (now using blue)
            LineChartBarData(
              spots: generateGraphData(aBlockData),
              isCurved: true,
              color: Colors.blue,
              barWidth: 4,
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  // Filter sensor data by location
  List<SensorData> filterDataByLocation(
      List<SensorData> data, String location) {
    return data.where((sensor) => sensor.location == location).toList();
  }

  // Generate graph data based on average MQ135 values over time
  List<FlSpot> generateGraphData(List<SensorData> data) {
    Map<String, List<double>> timeGroupedData = {};

    // Group data by time and calculate average MQ135 values
    for (var sensor in data) {
      if (!timeGroupedData.containsKey(sensor.time)) {
        timeGroupedData[sensor.time] = [];
      }
      timeGroupedData[sensor.time]!.add(sensor.mq135);
    }

    // Calculate average MQ135 for each time period
    List<FlSpot> graphData = [];
    timeGroupedData.forEach((time, values) {
      double avgValue = values.reduce((a, b) => a + b) / values.length;
      int timeIndex = timeToIndex(time);
      graphData.add(FlSpot(timeIndex.toDouble(), avgValue));
    });

    return graphData;
  }

  // Convert time (e.g., 8am, 10am, etc.) to an index for the X-axis
  int timeToIndex(String time) {
    switch (time) {
      case '8am':
        return 0;
      case '10am':
        return 1;
      case '12pm':
        return 2;
      case '3pm':
        return 3;
      case '5pm':
        return 4;
      case '7pm':
        return 5;
      case '9pm':
        return 6;
      default:
        return 0;
    }
  }
}
