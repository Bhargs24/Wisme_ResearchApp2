import 'package:flutter/material.dart';

void main() {
  print('=== SIMPLE MAIN STARTING ===');
  runApp(const SimpleTestApp());
}

class SimpleTestApp extends StatelessWidget {
  const SimpleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('=== SIMPLE APP BUILD ===');
    return MaterialApp(
      title: 'Simple Test',
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.green,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 64),
              SizedBox(height: 16),
              Text(
                'App Works!',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              SizedBox(height: 8),
              Text(
                'Basic Flutter app is running',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
