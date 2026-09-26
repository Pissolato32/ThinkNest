import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:thinknest/main.dart';

void main() {
  testWidgets('renders the ThinkNest quick capture shell', (tester) async {
    await tester.pumpWidget(const ThinkNestApp());

    expect(find.text('ThinkNest'), findsOneWidget);
    expect(find.text('Capture uma ideia.'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
