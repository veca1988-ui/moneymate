import 'package:flutter_test/flutter_test.dart';
import 'package:moneymate/src/app.dart';

void main() {
  testWidgets('MoneyMateApp can be instantiated', (tester) async {
    expect(const MoneyMateApp(), isA<MoneyMateApp>());
  });
}
