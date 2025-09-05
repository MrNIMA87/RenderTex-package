import 'package:math_expressions/math_expressions.dart';

class Calculator {
  final Parser _parser = Parser();
  final ContextModel _cm = ContextModel();

  Calculator();

  /// Evaluate a numeric expression like "2 + 3*4" -> 14.0
  double evaluate(String expr) {
    final exp = _parser.parse(expr);
    final result = exp.evaluate(EvaluationType.REAL, _cm);
    return (result is num) ? result.toDouble() : double.parse(result.toString());
  }

  /// Example: set variables like a=1, b=2 then evaluate "a+b"
  void setVariable(String name, num value) {
    _cm.bindVariable(Variable(name), Number(value));
  }
}
