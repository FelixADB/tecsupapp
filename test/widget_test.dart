import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:crud_test/main.dart';

void main() {
  testWidgets('App loads and shows Empresas screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for any async operations to complete
    await tester.pumpAndSettle();

    // Verify that the app shows the Empresas title
    expect(find.text('Empresas'), findsOneWidget);

    // Verify that the empty state message is shown
    expect(find.text('No hay empresas registradas'), findsOneWidget);

    // Verify that the floating action button is present
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}
