import 'dart:async';

import 'package:flutter/material.dart';

import '../models/vfd_status.dart';
import '../services/esp32_service.dart';

class VfdHomePage extends StatefulWidget {
  const VfdHomePage({super.key});

  @override
  State<VfdHomePage> createState() => _VfdHomePageState();
}

class _VfdHomePageState extends State<VfdHomePage> {
  final Esp32Service esp32 = Esp32Service();

  Timer? statusTimer;

  bool connected = false;
  bool motorRunning = false;

  int commandedSpeed = 0;

  @override
  void initState() {
    super.initState();

    updateStatus();

    statusTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => updateStatus(),
    );
  }

  @override
  void dispose() {
    statusTimer?.cancel();

    super.dispose();
  }

  Future<void> updateStatus() async {
    try {
      final VfdStatus status =
          await esp32.getStatus();

      if (!mounted) return;

      setState(() {
        connected = true;
        motorRunning = status.running;
        commandedSpeed = status.commandedSpeed;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        connected = false;
      });
    }
  }

  Future<void> sendCommand(
    String command,
  ) async {
    try {
      await esp32.sendCommand(command);

      await updateStatus();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not connect to ESP32',
          ),
        ),
      );
    }
  }

  Future<void> setSpeed(int rpm) async {
    try {
      await esp32.setSpeed(rpm);

      await updateStatus();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not set speed',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VFD Controller'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                Icon(
                  connected
                      ? Icons.wifi
                      : Icons.wifi_off,
                  color: connected
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  connected
                      ? 'Connected'
                      : 'Offline',
                ),
              ],
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.stretch,

          children: [
            buildStatusCard(),

            const SizedBox(height: 16),

            buildSpeedCard(),

            const SizedBox(height: 16),

            buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Text(
              'MOTOR STATUS',
              style: TextStyle(
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 12),

            Icon(
              motorRunning
                  ? Icons.settings
                  : Icons.stop_circle,
              size: 60,
              color: motorRunning
                  ? Colors.green
                  : Colors.grey,
            ),

            const SizedBox(height: 8),

            Text(
              motorRunning
                  ? 'RUNNING'
                  : 'STOPPED',

              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: motorRunning
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSpeedCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Text(
              'COMMANDED SPEED',
              style: TextStyle(
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '$commandedSpeed RPM',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Slider(
              value: commandedSpeed
                  .toDouble()
                  .clamp(0.0, 1800.0),

              min: 0,
              max: 1800,
              divisions: 180,

              label: '$commandedSpeed RPM',

              onChanged: (value) {
                setState(() {
                  commandedSpeed =
                      value.round();
                });
              },

              onChangeEnd: (value) {
                setSpeed(value.round());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildControlButtons() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: connected
                ? () => sendCommand('start')
                : null,

            icon: const Icon(Icons.play_arrow),
            label: const Text('START'),

            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(
                vertical: 18,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: FilledButton.icon(
            onPressed: connected
                ? () => sendCommand('stop')
                : null,

            icon: const Icon(Icons.stop),
            label: const Text('STOP'),

            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(
                vertical: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
