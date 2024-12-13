import 'package:cnproj_app/ComparisonGraph.dart';
import 'package:cnproj_app/HistoryDataPage.dart';
import 'package:cnproj_app/LiveDataPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'SensorData.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pollution Index Sensing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        textTheme: GoogleFonts.latoTextTheme(
          Theme.of(context).textTheme.apply(
                bodyColor: Colors.black87,
                displayColor: Colors.black87,
              ),
        ),
      ),
      home: SensorDataHome(),
    );
  }
}

class SensorDataHome extends StatefulWidget {
  @override
  _SensorDataHomeState createState() => _SensorDataHomeState();
}

class _SensorDataHomeState extends State<SensorDataHome> {
  List<SensorData> cachedData = [];
  List<SensorData> liveData = []; // Add this to hold live data
  bool isFetchingLiveData = false;
  bool isLiveDataAvailable = false;

  @override
  void initState() {
    super.initState();
    loadCachedDataFromAssets();
  }

  Future<void> loadCachedDataFromAssets() async {
    final String response =
        await rootBundle.loadString('assets/sensor_data.json');
    List jsonResponse = json.decode(response);

    setState(() {
      cachedData =
          jsonResponse.map((data) => SensorData.fromJson(data)).toList();
    });
  }

  Future<void> fetchLiveData() async {
    setState(() {
      isFetchingLiveData = true;
    });

    try {
      final response =
          await http.get(Uri.parse('http://192.168.102.173:5000/get_data'));

      if (response.statusCode == 200) {
        setState(() {
          List jsonResponse = json.decode(response.body);
          liveData =
              jsonResponse.map((data) => SensorData.fromJson(data)).toList();
          isLiveDataAvailable = liveData.isNotEmpty;
        });

        // Navigate to LiveDataPage if data is fetched successfully
        if (isLiveDataAvailable) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LiveDataPage(liveData)),
          );
        } else {
          showErrorDialog("No live data available.");
        }
      } else {
        showErrorDialog(
            "Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      showErrorDialog("ESP disconnected, error: $e");
      print('Error fetching live data: $e');
    }

    setState(() {
      isFetchingLiveData = false;
    });
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Connection Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void filterCachedData() {
    String comparisonResult = comparePollutionLevels();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Pollution Comparison Result"),
        content: Text(comparisonResult),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryDataPage(cachedData),
                ),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String comparePollutionLevels() {
    Map<String, double> locationPollution = {};
    Map<String, int> locationCounts = {};

    for (var data in cachedData) {
      double mq135Value = data.mq135;
      if (locationPollution.containsKey(data.location)) {
        locationPollution[data.location] =
            locationPollution[data.location]! + mq135Value;
        locationCounts[data.location] = locationCounts[data.location]! + 1;
      } else {
        locationPollution[data.location] = mq135Value;
        locationCounts[data.location] = 1;
      }
    }

    locationPollution.forEach((key, value) {
      locationPollution[key] = value / locationCounts[key]!;
    });

    var sortedLocations = locationPollution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    String result = "Pollution levels by location (highest to lowest):\n\n";
    for (var entry in sortedLocations) {
      result +=
          "${entry.key}: ${entry.value.toStringAsFixed(2)} (MQ135 average)\n";
    }
    return result;
  }

  void showGraph() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ComparisonGraph(data: cachedData), // Pass data to ComparisonGraph
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Pollution Index Sensing for VITCC",
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        backgroundColor: Colors.lightBlue,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF87CEEB), Color(0xFFFFD700)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Image.asset(
                "assets/gif4.gif",
                width: MediaQuery.of(context).size.width * 0.8,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: filterCachedData,
                    child: const Text('History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(fontSize: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: showGraph,
                    child: const Text('Show Graph'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(fontSize: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isFetchingLiveData ? null : fetchLiveData,
                    child: isFetchingLiveData
                        ? const CircularProgressIndicator()
                        : const Text('Fetch Live Data'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 20),
                      textStyle: const TextStyle(fontSize: 20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
