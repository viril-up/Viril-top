import 'package:flutter_test/flutter_test.dart';
import 'package:viril/app.dart';

void main() {
  testWidgets('Viril opens with five main sections', (tester) async {
    await tester.pumpWidget(const VirilApp());

    // The app now shows a 1.5-second splash screen before opening the shell.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Мои цели'), findsOneWidget);
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Развитие'), findsOneWidget);
    expect(find.text('Ресурсы'), findsOneWidget);
    expect(find.text('Прогресс'), findsOneWidget);
    expect(find.text('Профиль'), findsWidgets);
  });
}
