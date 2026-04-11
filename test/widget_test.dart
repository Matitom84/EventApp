import 'package:flutter_test/flutter_test.dart';
import 'package:application_p/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Test basique qui vérifie que l'app se lance sans crasher
    await tester.pumpWidget(const App());
  });
}