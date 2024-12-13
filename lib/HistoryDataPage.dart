import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'SensorData.dart';

class HistoryDataPage extends StatelessWidget {
  final List<SensorData> cachedData;

  HistoryDataPage(this.cachedData);

  @override
  Widget build(BuildContext context) {
    // Calculate average pollution levels for each location
    Map<String, double> locationAverages = {};
    Map<String, int> locationCounts = {};

    for (var data in cachedData) {
      double mq135Value = data.mq135;
      if (locationAverages.containsKey(data.location)) {
        locationAverages[data.location] =
            locationAverages[data.location]! + mq135Value;
        locationCounts[data.location] = locationCounts[data.location]! + 1;
      } else {
        locationAverages[data.location] = mq135Value;
        locationCounts[data.location] = 1;
      }
    }

    locationAverages.forEach((key, value) {
      locationAverages[key] = value / locationCounts[key]!;
    });

    // Determine the pollution levels for categorization
    double maxPollution =
        locationAverages.values.reduce((a, b) => a > b ? a : b);
    double minPollution =
        locationAverages.values.reduce((a, b) => a < b ? a : b);
    double thresholdModerate = (maxPollution + minPollution) / 2;

    // Function to get the color dot based on pollution level
    Widget getPollutionIndicator(double value) {
      if (value == maxPollution) {
        return const Icon(Icons.circle, color: Colors.red, size: 12);
      } else if (value >= thresholdModerate) {
        return const Icon(Icons.circle, color: Colors.yellow, size: 12);
      } else {
        return const Icon(Icons.circle, color: Colors.green, size: 12);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('History Data'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: ListView.builder(
        itemCount: cachedData.length,
        itemBuilder: (context, index) {
          final data = cachedData[index];
          double averagePollution = locationAverages[data.location] ?? 0;

          return ListTile(
            leading: getPollutionIndicator(averagePollution),
            title: Text(
              'Location: ${data.location}',
              style:
                  GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'MQ135: ${data.mq135}, MQ2: ${data.mq2}, MQ7: ${data.mq7}',
              style: GoogleFonts.lato(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
