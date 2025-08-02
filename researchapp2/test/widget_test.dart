// This is a basic Flutter widget test for Wisme Research App.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:researchapp2/main.dart';
import 'package:researchapp2/core/auth_provider.dart';
import 'package:researchapp2/core/research_metrics_provider.dart';

void main() {
  testWidgets('App loads without crash', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ResearchMetricsProvider()),
        ],
        child: const WismeResearchDemoApp(),
      ),
    );

    // Verify that the app loads (either shows loading or content)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
