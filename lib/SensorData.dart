class SensorData {
  final double temperature;
  final double humidity;
  final double mq2;
  final double mq7;
  final double mq135;
  final String location; // Add location field
  final String time; // Add time field as String

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.mq2,
    required this.mq7,
    required this.mq135,
    required this.location,
    required this.time, // Add time to the constructor
  });

  // Factory constructor to create a SensorData object from JSON
  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      mq2: (json['mq2'] as num).toDouble(),
      mq7: (json['mq7'] as num).toDouble(),
      mq135: (json['mq135'] as num).toDouble(),
      location: json['location'] as String, // Deserialize location
      time: json['time'] is String
          ? json['time'] // If time is a string, use it
          : json['time'].toString(), // Otherwise, convert it to a string
    );
  }

  // Method to convert SensorData object back to JSON format
  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'mq2': mq2,
      'mq7': mq7,
      'mq135': mq135,
      'location': location, // Serialize location
      'time': time, // Serialize time
    };
  }
}
