import 'package:flutter_test/flutter_test.dart';
import 'package:latex_math_renderer/src/calculator.dart';

void main() {
  test('adds one to input values', () {
    final calc = Calculator();
    calc.setVariable('a', 1);
    calc.setVariable('b', 2);
    final value = calc.evaluate('a + b'); // 3.0
  });
}
