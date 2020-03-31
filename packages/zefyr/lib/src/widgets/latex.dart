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
    final zefyrTheme = ZefyrTheme.of(context);
    var scope = ZefyrScope.of(context);
    List<Widget> items = [];
    Widget latexView;
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

    return Container(
      child: scope.mode.canEdit
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: items)
          : latexView ?? Container(),
    );
  }

  Widget _buildLine(Node node, TextStyle style, BuildContext context) {
    LineNode line = node;
    return ZefyrLine(node: line, style: style);
  }
}
