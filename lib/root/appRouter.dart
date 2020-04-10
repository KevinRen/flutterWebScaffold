import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum HandlerType {
  route,
  function,
}

enum TransitionType {
  inFromLeft,
  inFromRight,
  inFromBottom,
  fadeIn,
}

typedef Widget HandlerFunc(BuildContext context);

class Handler {
  Handler({this.type = HandlerType.route, this.handlerFunc});
  final HandlerType type;
  final HandlerFunc handlerFunc;
}

class RouteBuild {
  final String path;
  final Handler handler;
  final TransitionType transitionType;
  final bool isDefault;

  RouteBuild({
    @required this.path,
    @required this.handler,
    this.transitionType: TransitionType.fadeIn,
    this.isDefault: false
  });
}

class TargetPath {
  final String path;

  TargetPath({@required this.path});
}

class AppRouter {
  static Map<dynamic, RouteBuild> routers;

  static Route<dynamic> setupRouters(RouteSettings settings) => machRoute(settings.name, settings);

  static machRoute(String path, RouteSettings settings) {
    TargetPath _targetPath = filterPath(path);

    Route<dynamic> _route;
    routers.forEach((key, value) {
      if (value.path == _targetPath.path) {
        _route = _routeCreator(settings, value.handler.handlerFunc, value.transitionType);
      }
    });

    if (_route != null) {
      return _route;
    } else {
      routers.forEach((key, value) {
        if (value.isDefault == true) {
          _route = _routeCreator(settings, value.handler.handlerFunc, value.transitionType);
        }
      });
      return _route;
    }
  }

  static Route<dynamic> _routeCreator(RouteSettings settings, HandlerFunc handlerFunc, TransitionType transitionType) {
    Duration transitionDuration = Duration(milliseconds: 250);
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return handlerFunc(context);
      },
      transitionDuration: transitionDuration,
      transitionsBuilder: _standardTransitionsBuilder(transitionType),
    );
  }

  static RouteTransitionsBuilder _standardTransitionsBuilder(TransitionType transitionType) {
    return (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {

      if (transitionType == TransitionType.fadeIn) {
        return FadeTransition(opacity: animation, child: child);
      } else {
        const Offset topLeft = const Offset(0.0, 0.0);
        const Offset topRight = const Offset(1.0, 0.0);
        const Offset bottomLeft = const Offset(0.0, 1.0);
        Offset startOffset = bottomLeft;
        Offset endOffset = topLeft;
        if (transitionType == TransitionType.inFromLeft) {
          startOffset = const Offset(-1.0, 0.0);
          endOffset = topLeft;
        } else if (transitionType == TransitionType.inFromRight) {
          startOffset = topRight;
          endOffset = topLeft;
        }

        return SlideTransition(
          position: Tween<Offset>(
            begin: startOffset,
            end: endOffset,
          ).animate(animation),
          child: child,
        );
      }
    };
  }

  static TargetPath filterPath(String path) {
    List<String> _path = path.split('/');
    String _route = _path[1].contains('?') ? _path[1].split('?')[0] : _path[1];
    if (_route.isEmpty) {
      routers.forEach((key, value) {
        if (value.isDefault == true) _route = value.path;
      });
    }
    return TargetPath(path: _route);
  }
}