import 'package:flutter/material.dart';

typedef void OnKeyCallback(KeyInfo keyInfo);

enum KeyType { keyDown, keyUp }

class KeyInfo {
  final String code;
  final KeyType keyType;
  KeyInfo({ @required this.code, @required this.keyType });
}