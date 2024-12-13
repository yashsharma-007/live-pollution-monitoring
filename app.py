from flask import Flask, request, jsonify
import json

app = Flask(__name__)

# List to store sensor data
sensor_data_list = []

@app.route('/save_data', methods=['POST'])
def save_data():
    data = request.get_json()
    sensor_data_list.append(data)  # Save the data to the list

    # Write the data to the JSON file
    with open('sensor_data.json', 'w') as f:
        json.dump(sensor_data_list, f, indent=4)

    # Write the data to a text file
    with open('sensor_data.txt', 'a') as txt_file:  # 'a' to append data
        txt_file.write(json.dumps(data) + '\n')  # Write the JSON string and add a newline

    return jsonify({"message": "Data saved!"}), 200

@app.route('/get_data', methods=['GET'])
def get_data():
    # Read data from the JSON file
    with open('sensor_data.json', 'r') as f:
        data = json.load(f)
    return jsonify(data)

@app.route('/get_data/<location>', methods=['GET'])
def get_data_by_location(location):
    # Read data and filter by location
    with open('sensor_data.json', 'r') as f:
        data = json.load(f)
    filtered_data = [entry for entry in data if entry['location'] == location]
    return jsonify(filtered_data)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
