import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'utils/size.dart';
import 'utils/keyboard.dart';
import 'utils/http.dart';
//import 'utils/type.dart';

typedef void OnKeyCallback(KeyInfo keyInfo);

enum KeyType { keyDown, keyUp }

class KeyInfo {
  final String code;
  final KeyType keyType;
  KeyInfo({ @required this.code, @required this.keyType });
}

class RootView {
  final BuildContext context;

  RootView(this.context);

  Widget build({
    @required Widget body,
    OnKeyCallback onKey,
    bool isPage = true,
    Color backgroundColor: Colors.white
  }) {
    return isPage ? Scaffold(
      backgroundColor: backgroundColor,
      body: body == null ? Container() : RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          _manager(event, onKey);
        },
        child: body,
      ),
    ) : body == null ? Container() : RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          _manager(event, onKey);
        },
      child: body
    );
  }

  _manager(RawKeyEvent key, OnKeyCallback onKey) async {
    String _keyType = key.runtimeType.toString();
    print(key);
    if (_keyType == 'RawKeyDownEvent' || _keyType == 'RawKeyUpEvent') {
      RawKeyEventDataWeb data = key.data;

      print(data);
      onKey(KeyInfo(code: data.code, keyType: _keyType == 'RawKeyDownEvent' ? KeyType.keyDown : KeyType.keyUp));
    }
  }

  _onKey(KeyInfo keyInfo) {
    print(keyInfo);
  }

  gotoPage(String path, {String query, Map arguments}) {
    List _path = path.split('.');
    String _query = query != null ? '$query' : '';
    Navigator.of(context).pushNamed('/${_path[1]}$_query', arguments: arguments);
  }

  Map pageParams() => ModalRoute.of(context).settings.arguments;

  Map<String, String> pageQuery() {
    String _path = ModalRoute.of(context).settings.name;
    List<String> _pathSplit = _path.contains('?') ? _path.split('?') : List();
    Map<String, String> _query = Map();
    if (_pathSplit.length > 0) {
      List<String> _queryList = _pathSplit[1].split('&');
      _queryList.forEach((queryItem) {
        if (queryItem.contains('=')) {
          List<String> _itemSplit = queryItem.split('=');
          _query[_itemSplit[0]] = _itemSplit[1];
        }
      });
    }

    return _query;
  }

  void setHttpBaseUrl(String baseUrl) => HttpRequest.baseUrl = baseUrl;

  Future request({ @required String url,  Map data }) async {
    return await HttpRequest.request(url, data: data);
  }
}