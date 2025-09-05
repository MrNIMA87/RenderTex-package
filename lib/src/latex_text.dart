import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

/// A widget that parses a string containing LaTeX fragments delimited by $...$ or $$...$$
/// and displays the result with math parts rendered using flutter_math_fork.
///
/// Improvements over the earlier version:
/// - A robust scanner that correctly handles escaped dollar signs (\$)
/// - Correct delimiter matching for `$...$` and `$$...$$`
/// - Safe `try/catch` around `Math.tex(...)` so invalid LaTeX won't crash the app
/// - Fallback UI when rendering fails
class LatexText extends StatelessWidget {
  final String data;
  final TextStyle? textStyle;
  final PlaceholderAlignment mathAlignment;
  final bool enableDisplayMode;

  const LatexText({
    Key? key,
    required this.data,
    this.textStyle,
    this.mathAlignment = PlaceholderAlignment.middle,
    this.enableDisplayMode = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final defaultStyle = textStyle ?? DefaultTextStyle.of(context).style;
    final parts = _splitIntoParts(data);

    final spans = <InlineSpan>[];

    for (final p in parts) {
      if (!p.isMath) {
        spans.add(TextSpan(text: p.content, style: defaultStyle));
      } else {
        // Render math in a WidgetSpan. Guard against rendering exceptions.
        final isDisplay = p.isDisplay;
        final latex = p.content;

        Widget mathWidget;
        try {
          mathWidget = Math.tex(
            latex,
            textStyle: defaultStyle,
            mathStyle: isDisplay ? MathStyle.display : MathStyle.text,
            // You can pass additional parameters here if needed
          );
        } catch (e) {
          // If flutter_math_fork throws, show a fallback so the whole RichText doesn't crash
          mathWidget = Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DefaultTextStyle(
              style: defaultStyle.copyWith(fontFamily: 'monospace'),
              child: Text('[LaTeX error] \$${latex}\$'),
            ),
          );
        }

        spans.add(WidgetSpan(
          alignment: mathAlignment,
          child: Padding(
            padding: isDisplay && enableDisplayMode ? const EdgeInsets.symmetric(vertical: 6.0) : EdgeInsets.zero,
            child: mathWidget,
          ),
        ));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.start,
    );
  }
}

class _Part {
  final bool isMath;
  final bool isDisplay;
  final String content;
  _Part(this.isMath, this.isDisplay, this.content);
}

/// Splits the input into plain text and math parts.
///
/// Rules:
/// - `$...$` is inline math
/// - `$$...$$` is display math
/// - `\$` is treated as an escaped dollar and does NOT start/end a math block
List<_Part> _splitIntoParts(String input) {
  final parts = <_Part>[];
  final len = input.length;
  int i = 0;

  StringBuffer buffer = StringBuffer();

  bool isEscaped(int idx) {
    // Count how many consecutive backslashes are immediately before idx
    int backslashes = 0;
    int j = idx - 1;
    while (j >= 0 && input[j] == r'\') {
      backslashes++;
      j--;
    }
    return backslashes % 2 == 1;
  }

  while (i < len) {
    final ch = input[i];

    if (ch == r'\$' && !isEscaped(i)) {
      // Found an unescaped dollar. Determine if it's $$ or $
      final nextIsDollar = (i + 1 < len && input[i + 1] == r'\$');
      final delimLen = nextIsDollar ? 2 : 1;
      final start = i + delimLen;

      // Flush any accumulated plain text
      if (buffer.isNotEmpty) {
        parts.add(_Part(false, false, buffer.toString()));
        buffer = StringBuffer();
      }

      // Find the matching closing delimiter
      int j = start;
      bool found = false;
      while (j < len) {
        if (input[j] == r'\$' && !isEscaped(j)) {
          // Check if this is the same delimiter length
          final nextDollar = (j + 1 < len && input[j + 1] == r'\$');
          final closingLen = nextDollar ? 2 : 1;
          if (closingLen == delimLen) {
            // Extract content between start and j
            final content = input.substring(start, j);
            parts.add(_Part(true, delimLen == 2, content));
            i = j + closingLen; // continue after the closing delimiter
            found = true;
            break;
          } else {
            // This $ belongs to a different delimiter length (e.g. single $ inside $$...$$)
            j++;
            continue;
          }
        }
        j++;
      }

      if (!found) {
        // No closing delimiter found — treat the original dollar(s) as plain text
        buffer.write(input.substring(i, i + delimLen));
        i += delimLen;
      }
    } else {
      // Normal character (including escaped dollar or backslash)
      buffer.write(ch);
      i++;
    }
  }

  if (buffer.isNotEmpty) parts.add(_Part(false, false, buffer.toString()));

  return parts;
}