import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:notus/notus.dart';

import 'common.dart';
import 'scope.dart';
import 'theme.dart';

/// Represents a code snippet in Zefyr editor.
class ZefyrLatex extends StatefulWidget {
  const ZefyrLatex({Key key, @required this.node}) : super(key: key);

  /// Document node represented by this widget.
  final BlockNode node;

  @override
  _ZefyrLatexState createState() => _ZefyrLatexState();
}

class _ZefyrLatexState extends State<ZefyrLatex> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final zefyrTheme = ZefyrTheme.of(context);
    var scope = ZefyrScope.of(context);
    List<Widget> items = [];
    Widget latexView = Container();
    String text = '';

    if (scope.mode.canEdit) {
      for (var line in widget.node.children) {
        items.add(_buildLine(
            line, zefyrTheme.attributeTheme.code.textStyle, context));
      }
    } else {
      for (var line in widget.node.children) {
        text += line.toPlainText();
      }
      latexView = TeXView(
        keepAlive: true,
        teXHTML: text,
        renderingEngine: RenderingEngine.Katex,
        onRenderFinished: (height) {
          print("Widget Height is : $height");
        },
        onPageFinished: (string) {
          print("Page Loading finished");
        },
      );
    }

    final color = Colors.grey.shade200;
    return Padding(
      padding: zefyrTheme.attributeTheme.code.padding,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: scope.mode.canEdit
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch, children: items)
            : latexView,
      ),
    );
  }

  Widget _buildLine(Node node, TextStyle style, BuildContext context) {
    LineNode line = node;
    return ZefyrLine(node: line, style: style);
  }
}
