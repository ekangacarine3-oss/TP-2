import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cv_flutter_tp2/main.dart';

void main() {
  testWidgets('Affiche la page de connexion de MonCvApp', (WidgetTester tester) async {
    await tester.pumpWidget(const MonCvApp());
    expect(find.text('Connexion'), findsOneWidget);
    expect(find.text('Se connecter'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });
}
