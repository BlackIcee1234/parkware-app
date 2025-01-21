import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parkware/presentation/views/virtual/virtual_queue_registration_screen.dart';
import 'package:parkware/domain/models/attraction.dart';

void main() {
  testWidgets('Test de registro en la fila virtual', (WidgetTester tester) async {
    Attraction attraction = Attraction(
      name: 'Nombre de la atracción',
      description: 'Descripción de la atracción',
      price: 10.0,
      imageUrls: ['url1', 'url2'],
    );

    await tester.pumpWidget(MaterialApp(
      home: VirtualQueueRegistrationPage(
        attraction: attraction,
        personsCount: 3,
      ),
    ));

    await tester.enterText(find.byType(TextField), 'Código de registro');

    await tester.tap(find.byType(ElevatedButton));

    await tester.pump();

    expect(find.text('Código de registro'), findsOneWidget);
  });
}
