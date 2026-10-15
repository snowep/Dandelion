import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dandelion/app/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DandelionApp());
    await tester.pumpAndSettle();
    expect(find.byType(DandelionApp), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
