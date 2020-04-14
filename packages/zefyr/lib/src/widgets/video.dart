import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:notus/notus.dart';

import 'common.dart';
import 'scope.dart';
import 'theme.dart';

/// Represents a code snippet in Zefyr editor.
class ZefyrVideo extends StatelessWidget {
  ZefyrVideo({Key key, @required this.node}) : super(key: key);

  /// Document node represented by this widget.
  final BlockNode node;

  @override
  Widget build(BuildContext context) {
    final zefyrTheme = ZefyrTheme.of(context);
    var scope = ZefyrScope.of(context);
    List<Widget> items = [];
    Widget videoView;

    if (scope.mode.canEdit) {
      for (var line in node.children) {
        items.add(_buildLine(
            line, zefyrTheme.attributeTheme.code.textStyle, context));
      }
    } else {
      videoView = iFrameVideo();
    }

    return Container(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 360, maxWidth: 640),
          child: scope.mode.canEdit
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: items)
              : videoView ?? Container(),
        ));
  }

  Widget _buildLine(Node node, TextStyle style, BuildContext context) {
    LineNode line = node;
    return ZefyrLine(node: line, style: style);
  }

  Widget iFrameVideo() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('video-${node.toPlainText()}',
        (int viewId) {
      return IFrameElement()
        ..width = '640'
        ..height = '360'
        ..src = node.toPlainText()
        ..style.border = 'none';
    });
    return HtmlElementView(viewType: 'video-${node.toPlainText()}');
  }
}
