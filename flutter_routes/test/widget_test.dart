import 'package:flutter/material.dart';
import 'package:flutter_lab6/main.dart';
import 'package:flutter_lab6/noArguments.dart' as arg;
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Тест курильщика', (WidgetTester tester) async {
    await tester.pumpWidget(arg.MyApp()).then((f){
      expect(find.byType(MaterialApp), findsWidgets);
    });
  });

  testWidgets('Тест на гетеросексуала', (WidgetTester tester) async {
    await tester.pumpWidget(HomeScreen()).then((f){
      expect(find.text('Что-то не так'), findsWidgets);
    });
  });
}
