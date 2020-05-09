// Copyright (c) 2018, the Zefyr project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zefyr/zefyr.dart';

/// Custom image delegate used by this example to load image from application
/// assets.
class CustomVideoDelegate implements ZefyrVideoDelegate {
  CustomVideoDelegate(this.context);

  TextEditingController controller = TextEditingController();

  final BuildContext context;

  @override
  Future<String> pickVideo() async {
    String response = await showAlertDialog(context);
    return response?.toString() ?? "";
  }

  @override
  Widget buildVideo(BuildContext context, String key) {
    // We use custom "asset" scheme to distinguish asset images from other files.
    if (key.startsWith('asset://')) {
      final asset = AssetImage(key.replaceFirst('asset://', ''));
      return Image(image: asset);
    } else {
      return Video(node: key);
      ;
    }
  }

  Future<T> showAlertDialog<T>(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.0)),
          title: Text(
            "Add Video",
            style: TextStyle(fontSize: 22.0),
          ),
          content: IntrinsicHeight(
              child: Column(children: [
            Row(
              children: <Widget>[
                Expanded(
                    child: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: 'Add a video Url'),
                )),
                IconButton(
                  icon: Icon(Icons.send),
                  iconSize: 40.0,
                  color: Color.fromRGBO(88, 60, 26, 1),
                  onPressed: () async {
                    Navigator.of(context).pop(controller.text);
                  },
                ),
              ],
            ),
          ])),
          actions: [
            FlatButton(
              child: Text(
                "Cancel",
                style: TextStyle(
                    color: Color.fromRGBO(88, 60, 26, 1), fontSize: 17.0),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class Video extends StatelessWidget {
  Video({Key key, @required this.node}) : super(key: key);

  /// Document node represented by this widget.
  final String node;

  @override
  Widget build(BuildContext context) {
    Widget videoView = iFrameVideo();

    return Container(
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 360, maxWidth: 640),
          child: videoView ?? Container(),
        ));
  }

  Widget iFrameVideo() {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('video-${node}', (int viewId) {
      return IFrameElement()
        ..width = '640'
        ..height = '360'
        ..src = node
        ..style.border = 'none';
    });
    return HtmlElementView(viewType: 'video-${node}');
  }
}
