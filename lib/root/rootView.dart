import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/http.dart';
import 'utils/socket.dart';
import 'comm/comm.dart';
import 'comm.dart';

typedef void OnKeyCallback(KeyInfo keyInfo);

enum KeyType { keyDown, keyUp }

class KeyInfo {
  final String code;
  final KeyType keyType;
  KeyInfo({ @required this.code, @required this.keyType });
}

class RootView {
  final BuildContext context;
  final SocketUtil socketUtil = SocketUtil();

  RootView(this.context);

  Widget build({
    @required Widget body,
    OnKeyCallback onKeyCallback,
    bool isPage = true,
    Color backgroundColor: Colors.white
  }) {
    return isPage ? Scaffold(
      backgroundColor: backgroundColor,
      body: body == null ? Container() : RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          _keyOnManager(event, onKeyCallback);
        },
        child: body,
      ),
    ) : body == null ? Container() : RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (RawKeyEvent event) {
          _keyOnManager(event, onKeyCallback);
        },
      child: body
    );
  }

  _keyOnManager(RawKeyEvent key, OnKeyCallback onKey) async {
    String _keyType = key.runtimeType.toString();
    if (_keyType == 'RawKeyDownEvent' || _keyType == 'RawKeyUpEvent') {
      RawKeyEventDataWeb data = key.data;

      if (onKey != null) onKey(KeyInfo(code: data.code, keyType: _keyType == 'RawKeyDownEvent' ? KeyType.keyDown : KeyType.keyUp));
    }
  }

  gotoPage(String path, {Map query, Map arguments}) {
    List _path = path.split('.');
    String _query = query != null ? '${Comm.mapToQuery(query)}' : '';
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

  Future request(RequestBuilder requestBuilder) async => await HttpRequest.request(requestBuilder);

  SocketUtil socketConnect(String url, String params) {
    socketUtil.open(url, params);
    return socketUtil;
  }

  void socketClose() => socketUtil.close();

  void socketReset() => socketUtil.reopen();
}