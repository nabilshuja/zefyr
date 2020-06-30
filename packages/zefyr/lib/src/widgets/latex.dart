import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:meta/meta.dart';

import '../../zefyr.dart';
import 'theme.dart';

/// Represents a code snippet in Zefyr editor.
class ZefyrLatex extends StatelessWidget {
  const ZefyrLatex({Key key, @required this.node, this.height})
      : super(key: key);

  /// Document node represented by this widget.
  final BlockNode node;
  final double height;

  @override
  Widget build(BuildContext context) {
    final zefyrTheme = ZefyrTheme.of(context);
    var scope = ZefyrScope.of(context);
    var items = <Widget>[];
    Widget latexView;

    if (scope.mode.canEdit) {
      for (var line in node.children) {
        items.add(_buildLine(
            line, zefyrTheme.attributeTheme.code.textStyle, context));
      }
    }

    latexView = TeXView(
        keepAlive: true,
        teXHTML: node.toPlainText(),
        height: height ?? 75,
        renderingEngine: RenderingEngine.Katex);

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
