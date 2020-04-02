import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:notus/notus.dart';

import 'common.dart';
import 'scope.dart';
import 'theme.dart';

/// Represents a code snippet in Zefyr editor.
class ZefyrVideo extends StatefulWidget {
  //TODO: should rely on embed
  const ZefyrVideo({Key key, @required this.node}) : super(key: key);

  /// Document node represented by this widget.
  final BlockNode node;

  @override
  _ZefyrVideoState createState() => _ZefyrVideoState();
}

class _ZefyrVideoState extends State<ZefyrVideo> {
  String src = '';

  @override
  void initState() {
    for (var line in widget.node.children) {
      src += line.toPlainText();
    }

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
        'video-$src',
        (int viewId) => IFrameElement()
          ..width = '640'
          ..height = '360'
          ..src = src
          ..style.border = 'none');

    super.initState();
  }

  @override
  void dispose() {
    src = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zefyrTheme = ZefyrTheme.of(context);
    var scope = ZefyrScope.of(context);
    List<Widget> items = [];
    Widget videoView;

    if (scope.mode.canEdit) {
      for (var line in widget.node.children) {
        items.add(_buildLine(
            line, zefyrTheme.attributeTheme.code.textStyle, context));
      }
    } else {
      videoView = Container(
          height: 250,
          child: HtmlElementView(key: UniqueKey(), viewType: 'video-$src'));
    }

    return Container(
      child: scope.mode.canEdit
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, children: items)
          : videoView ?? Container(),
    );
  }

  Widget _buildLine(Node node, TextStyle style, BuildContext context) {
    LineNode line = node;
    return ZefyrLine(node: line, style: style);
  }
}
