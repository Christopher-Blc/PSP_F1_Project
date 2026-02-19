import 'package:f1api/main.dart';
import 'package:f1api/repositories/f1_repository.dart';
import 'package:f1api/services/jolpi_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home muestra botones principales', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp(repository: F1Repository(JolpiApiClient())));

    expect(find.text('Drivers'), findsOneWidget);
    expect(find.text('Teams'), findsOneWidget);
    expect(find.text('Circuits'), findsOneWidget);
    expect(find.text('Seasons'), findsOneWidget);
  });
}
