import 'package:flutter_test/flutter_test.dart';
import 'package:covant_app/main.dart';

void main() {
  testWidgets('COVANT app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const CovantApp());
    expect(find.text('COVANT'), findsWidgets);
    expect(find.text('Selamat Datang di Covant.'), findsOneWidget);
  });
}
