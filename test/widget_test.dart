import 'package:flutter_test/flutter_test.dart';

import 'package:dandelion/app/app.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DandelionApp());
    expect(find.byType(DandelionApp), findsOneWidget);
  });
}
