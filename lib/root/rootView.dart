import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'utils/http.dart';
import 'comm/comm.dart';
import 'comm.dart';
import 'package:dio/dio.dart';
import 'utils/map.dart';

typedef void OnKeyCallback(KeyInfo keyInfo);
typedef Interceptor(Map response);

class RootConfig {
  final String baseUrl;

  RootConfig({
    @required this.baseUrl,
  });
}

enum KeyType { keyDown, keyUp }

class KeyInfo {
  final String code;
  final KeyType keyType;
  KeyInfo({ @required this.code, @required this.keyType });
}

class RootView {
  final BuildContext context;
  final RootConfig config;

  RootView(this.context, {this.config});

  Widget build({
    @required Widget body,
    OnKeyCallback onKeyCallback,
    bool isPage = true,
    Color backgroundColor: Colors.white
  }) {
    print('++++++++++++++++++++++ ${HttpRequest.baseUrl}');
    if (config != null && HttpRequest.baseUrl != null) {
      HttpRequest.baseUrl = config.baseUrl;
      print('********************* ${HttpRequest.baseUrl}');
    }

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

  Future request(RequestBuilder requestBuilder) async {
    try {
      Map response = await HttpRequest.request(requestBuilder);
      if (MapUtil.getNum(response, 'result') > 0) {
        if (response == null || response['data'] == null) {
//        ToastUtil.show('数据异常,请联系管理员!');
          throw Error();
        } else if (MapUtil.getNum(response, 'result') == 101) {
          print('...非强制更新');
          return response;
        } else {
          return response;
        }
      } else {
        if (MapUtil.getNum(response, 'result') == -101) {
          print('...强制更新');
        } else if (MapUtil.getNum(response, 'result') == -100) {
          /// TODO:
          print('未登录');
        } else {
          print(MapUtil.getStr(response, 'message'));
        }
      }
//      return config.interceptor == null ? response : config.interceptor(response);
    } on DioError catch (e) {
      print(e);
      throw Error();
    }
  }
}