import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:notus/notus.dart';

import 'common.dart';
import 'scope.dart';
import 'theme.dart';

class ZefyrExpandable extends StatefulWidget {
  ZefyrExpandable({Key key, @required this.node}) : super(key: key);

  /// Document node represented by this
  final BlockNode node;

  @override
  _ZefyrExpandableState createState() => _ZefyrExpandableState();
}

class _ZefyrExpandableState extends State<ZefyrExpandable> {
  var controller = ExpandableController();

  @override
  Widget build(BuildContext context) {
    final zefyrTheme = ZefyrTheme.of(context);
    var scope = ZefyrScope.of(context);
    List<Widget> items = [];
    Widget expandableView;

    if (scope.mode.canEdit) {
      for (var line in widget.node.children) {
        items.add(_buildLine(
            line, zefyrTheme.attributeTheme.code.textStyle, context));
      }
    } else {
      expandableView = ExpandablePanel(
          controller: controller,
          header: GestureDetector(
              onLongPress: () {
                print('clicked');
              },
              child: Padding(
                  padding: EdgeInsets.all(16),
                  child: ZefyrLine(
                      node: widget.node.children.first,
                      style: zefyrTheme.attributeTheme.heading3.textStyle))),
          expanded: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.node.children?.map((line) {
                    return widget.node.children.first == line
                        ? Container()
                        : ZefyrLine(
                            node: line,
                            style: zefyrTheme.attributeTheme.code.textStyle);
                  })?.toList() ??
                  [Container()]));
    }

    return scope.mode.canEdit
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: items)
        : expandableView ?? Container();
  }

  Widget _buildLine(Node node, TextStyle style, BuildContext context) {
    LineNode line = node;
    return ZefyrLine(node: line, style: style);
  }
}
