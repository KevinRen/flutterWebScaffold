import 'package:flutter/material.dart';
import 'package:web_scaffold/web_scaffold.dart';
import 'utils/http.dart';
import 'utils/socket.dart';
import 'utils/size.dart';
import 'comm/comm.dart';
import 'comm.dart';
import 'package:web_socket_channel/html.dart';

enum PageType {
  Root,
  Page,
  Component,
}

extension PageTypeExtension on PageType {
  Widget build(Widget body, {
    Color backgroundColor: Colors.white,
    ThemeData themeData,
  }) {
    switch(this) {
      case PageType.Root:
        if (AppEnv.useScreenSize) {
          AppSize.init(width: 750, height: 1334, allowFontScaling: false);
        }
        return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeData == null ? defaultTheme : themeData,
            onGenerateRoute: AppRouter.setupRouters,
            home: Scaffold(
              backgroundColor: backgroundColor,
              body: body,
            ),
        );
      case PageType.Page:
        return Scaffold(
          backgroundColor: backgroundColor,
          body: body,
        );
      default:
        return body;
    }
  }
}

ThemeData defaultTheme = ThemeData(
  highlightColor: Colors.transparent,
  splashColor: Colors.transparent,
  primaryColor: Colors.white,
  backgroundColor: Colors.white,
);

class RootView {
  final SocketUtil socketUtil = SocketUtil();

  Widget build({
    @required Widget body,
    PageType type = PageType.Component,
    Color backgroundColor: Colors.white,
    ThemeData themeData,
  }) => type.build(body, backgroundColor: backgroundColor, themeData: themeData);

  Env get getEnv => AppEnv.env;

  gotoPage(BuildContext context, {
      String path,
      Map query,
      Map arguments
    }
  ) {
    List _path = path.split('.');
    String _query = query != null ? '${Comm.mapToQuery(query)}' : '';
    Navigator.of(context).pushNamed('/${_path[1]}$_query', arguments: arguments);
  }

  Map pageParams(BuildContext context) => ModalRoute.of(context).settings.arguments;

  Map<String, String> pageQuery(BuildContext context) {
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

  double size(double size) => AppEnv.useScreenSize ? AppSize().size(size) : size;

  double fontSize(double size) => AppEnv.useScreenSize ? AppSize().setSp(size) : size;

  Map<String, double> screenInfo() => {'width': AppSize.screenWidth, 'height': AppSize.screenHeight};

  Future request(RequestBuilder requestBuilder) async => await HttpRequest.request(requestBuilder);

  SocketUtil socketConnect(String url, String params) {
    socketUtil.open(url);
    return socketUtil;
  }

  HtmlWebSocketChannel getSocketChannel() => socketUtil.getChannel;

  void socketClose() => socketUtil.close();

  void socketReset(String url) => socketUtil.reopen(url);
}