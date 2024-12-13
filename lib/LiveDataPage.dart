import 'package:flutter/material.dart';

import 'SensorData.dart';

class LiveDataPage extends StatelessWidget {
  final List<SensorData> liveData;

  LiveDataPage(this.liveData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Data'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: liveData.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ListView.builder(
                    itemCount: liveData.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: const Icon(Icons.thermostat_outlined,
                            color: Colors.blueAccent),
                        title: Text(
                          'Temperature: ${liveData[index].temperature} °C',
                          style: const TextStyle(fontSize: 18),
                        ),
                        subtitle:
                            Text('Humidity: ${liveData[index].humidity} %'),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('MQ-2: ${liveData[index].mq2}'),
                            Text('MQ-7: ${liveData[index].mq7}'),
                            Text('MQ-135: ${liveData[index].mq135}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            )
          : const Center(child: Text("No live data available.")),
    );
  }
}
