import 'package:flutter_test/flutter_test.dart';
import 'package:viril/app.dart';

void main() {
  testWidgets('Viril opens with five main sections', (tester) async {
    await tester.pumpWidget(const VirilApp());
    expect(find.text('Viril'), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Развитие'), findsOneWidget);
    expect(find.text('Ресурсы'), findsOneWidget);
    expect(find.text('Прогресс'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);
  });
}
