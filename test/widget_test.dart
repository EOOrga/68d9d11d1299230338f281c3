import 'package:bessieres_operations/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navigates core operations sections', (tester) async {
    await tester.pumpWidget(
      BessieresOperationsApp(repository: InMemoryOperationsRepository.seeded()),
    );
    await tester.pumpAndSettle();

    expect(find.text('BESSIERES GERALDINE'), findsOneWidget);
    expect(find.text('Lead pipeline'), findsNothing);

    await tester.tap(find.text('Leads'));
    await tester.pumpAndSettle();

    expect(find.text('Lead pipeline'), findsOneWidget);
    expect(find.text('Nord Port Services'), findsOneWidget);

    await tester.tap(find.text('Team'));
    await tester.pumpAndSettle();

    expect(find.text('Employee directory'), findsOneWidget);
    expect(find.text('Camille Laurent'), findsOneWidget);

    await tester.tap(find.text('Boxes'));
    await tester.pumpAndSettle();

    expect(find.text('Container tracking'), findsOneWidget);
    expect(find.text('BSG-2047'), findsOneWidget);
  });

  testWidgets('adds a local lead from the lead form', (tester) async {
    await tester.pumpWidget(
      BessieresOperationsApp(repository: InMemoryOperationsRepository.seeded()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Leads'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'Canal Pro');
    await tester.enterText(find.byType(TextField).at(1), 'Iris Blanc');
    await tester.enterText(find.byType(TextField).at(2), 'Confirm visit');
    await tester.enterText(find.byType(TextField).at(3), 'Needs Monday slot');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Canal Pro'), findsOneWidget);
    expect(find.text('Iris Blanc'), findsOneWidget);
  });
}
