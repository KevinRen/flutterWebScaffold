import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

typedef OnKeyCallback(KeyInfo keyInfo);

enum KeyType { keyDown, keyUp }

class KeyInfo {
  final int code;
  final KeyType keyType;
  KeyInfo({ @required this.code, @required this.keyType });
}


class BrowserKeyboard extends StatelessWidget {
  final Widget child;
  final bool autoFocus;
  final FocusNode focusNode;
  final OnKeyCallback onKeyCallback;

  BrowserKeyboard({
    @required this.child,
    @required this.onKeyCallback,
    this.autoFocus = false,
    this.focusNode,
  });

  _manager(RawKeyEvent key) {
    String _keyType = key.runtimeType.toString();
    if (_keyType == 'RawKeyDownEvent' || _keyType == 'RawKeyUpEvent') {
      RawKeyEventDataWeb data = key.data as RawKeyEventDataWeb;
      onKeyCallback(KeyInfo(code: int.parse(data.code), keyType: _keyType == 'RawKeyDownEvent' ? KeyType.keyDown : KeyType.keyUp));
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      focusNode: focusNode != null ? focusNode : FocusNode(),
      autofocus: autoFocus,
      onKey: _manager,
      child: child,
    );
  }
}
