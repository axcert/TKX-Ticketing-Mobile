// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tkx_ticketing/main.dart';
import 'package:tkx_ticketing/services/connectivity_service.dart';

// Mock ConnectivityService
class MockConnectivityService implements ConnectivityService {
  @override
  Future<void> initialize() async {
    // Mock initialization
  }

  @override
  bool get isOffline => false;

  @override
  bool get isOnline => true;

  @override
  Future<void> checkConnectivity() async {}

  @override
  void dispose() {}

  @override
  void addListener(VoidCallback listener) {}

  @override
  bool get hasListeners => false;

  @override
  void notifyListeners() {}

  @override
  void removeListener(VoidCallback listener) {}
}

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create a mock ConnectivityService
    final mockConnectivityService = MockConnectivityService();
    await mockConnectivityService.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MyApp(connectivityService: mockConnectivityService),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
