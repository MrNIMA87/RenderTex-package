import 'package:flutter/material.dart';
import 'package:latex_math_renderer/latex_math_renderer.dart';


void main() => runApp(ExampleApp());


class ExampleApp extends StatelessWidget {
@override
Widget build(BuildContext context) {
return MaterialApp(
home: Scaffold(
appBar: AppBar(title: Text('LaTeX Text Example')),
body: Padding(
padding: const EdgeInsets.all(16.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
LatexText(
data:
'این یک متن نمونه است که شامل فرمول است: $\frac{-b \pm \sqrt{b^2 - 4ac}}{2a}$ و همچنین یک فرمول بلاک: $$E = mc^2$$ ادامهٔ متن.',
),
],
),
),
),
);
}
}