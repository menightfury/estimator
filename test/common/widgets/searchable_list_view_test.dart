import 'package:estimator/common/widgets/searchable_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('displays options after typing', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 300,
            child: SearchableListView<String>(
              optionsBuilder: (textEditingValue) => ['Satya', 'Subho', 'Jyoti'],
              optionViewBuilder: (context, option, isHighlighted, onSelected) =>
                  ListTile(title: Text(option)),
            ),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'S');
    await tester.pumpAndSettle();

    expect(find.text('Satya'), findsOneWidget);
    expect(find.text('Subho'), findsOneWidget);
    expect(find.text('Jyoti'), findsOneWidget);
  });
}
