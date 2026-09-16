import 'dart:convert';

//import 'package:http/http.dart' as http; check this out later

import '../models/vfd_status.dart';

class Esp32Service {
  final String baseUrl = 'http://192.168.4.1';

  Future<VfdStatus> getStatus() async {
    final response = await http
        .get(
          Uri.parse('$baseUrl/status'),
        )
        .timeout(
          const Duration(seconds: 3),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'ESP32 returned status ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    return VfdStatus.fromJson(data);
  }

  Future<void> sendCommand(
    String command,
  ) async {
    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/command?value=$command',
          ),
        )
        .timeout(
          const Duration(seconds: 3),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Command failed: ${response.statusCode}',
      );
    }
  }

  Future<void> setSpeed(int rpm) async {
    final response = await http
        .get(
          Uri.parse(
            '$baseUrl/command?value=speed&rpm=$rpm',
          ),
        )
        .timeout(
          const Duration(seconds: 3),
        );

    if (response.statusCode != 200) {
      throw Exception(
        'Speed command failed: ${response.statusCode}',
      );
    }
  }
}
