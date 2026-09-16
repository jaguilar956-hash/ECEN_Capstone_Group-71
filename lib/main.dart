import 'package:flutter/material.dart';

import 'screens/vfd_home_page.dart';

void main() {
  runApp(const VfdApp());
}

class VfdApp extends StatelessWidget {
  const VfdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VFD Controller',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const VfdHomePage(),
    );
  }
}
