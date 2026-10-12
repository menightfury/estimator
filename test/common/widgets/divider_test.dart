import 'package:estimator/common/widgets/divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('horizontal divider gets nonzero paint bounds', (tester) async {
    const key = Key('divider-boundary');
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox(width: 20, height: 5, child: EstimatorDivider(thickness: 5, colors: [Colors.red])),
          ),
        ),
      ),
    );

    final customPaint = find.descendant(of: find.byKey(key), matching: find.byType(CustomPaint));
    expect(tester.getSize(customPaint), const Size(20, 5));
  });

  testWidgets('vertical divider gets nonzero paint bounds', (tester) async {
    const key = Key('divider-boundary');
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: SizedBox(
              width: 5,
              height: 20,
              child: EstimatorDivider(direction: Axis.vertical, thickness: 5, colors: [Colors.red]),
            ),
          ),
        ),
      ),
    );

    final customPaint = find.descendant(of: find.byKey(key), matching: find.byType(CustomPaint));
    expect(tester.getSize(customPaint), const Size(5, 20));
  });
}
