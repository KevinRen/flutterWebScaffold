//import 'package:flutter/services.dart';
//import 'package:flutter/material.dart';
//
//class BrowserKeyboard extends StatelessWidget {
//  final Widget child;
//  final bool autoFocus;
//  final FocusNode focusNode;
//  final OnKeyCallback onKeyCallback;
//
//  BrowserKeyboard({
//    @required this.child,
//    @required this.onKeyCallback,
//    this.autoFocus = false,
//    this.focusNode,
//  });
//
//  _manager(RawKeyEvent key) async {
//    String _keyType = key.runtimeType.toString();
//    print(key);
//    if (_keyType == 'RawKeyDownEvent' || _keyType == 'RawKeyUpEvent') {
//      RawKeyEventDataWeb data = key.data;
//
//      print(data);
//      onKeyCallback(KeyInfo(code: data.code, keyType: _keyType == 'RawKeyDownEvent' ? KeyType.keyDown : KeyType.keyUp));
//    }
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return RawKeyboardListener(
//      focusNode: focusNode != null ? focusNode : FocusNode(),
//      autofocus: autoFocus,
//      onKey: _manager,
//      child: child,
//    );
//  }
//}
