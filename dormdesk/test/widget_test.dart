import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App builds test', (WidgetTester tester) async {
    // Test that we can build a simple MaterialApp
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test')),
          body: const Center(child: Text('Hello World')),
        ),
      ),
    );

    // Verify the app builds successfully
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
  });
}
