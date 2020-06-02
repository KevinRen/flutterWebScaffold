import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/status.dart' as status;

typedef VoidCallback = void Function(String message);

class SocketUtil {
  static const String _TAG = "###SocketUtil###";

  static const Duration pingTime = Duration(seconds: 2);

  HtmlWebSocketChannel _channel;
  String _url;
  bool _isConnect = false;
  VoidCallback _callback;
  Function _onDone;
  Function _onError;

  Future open(String url, String params) async {
    String sign = '';
    if (_channel != null) {
      _channel.sink.close();
    }
    _url = '$url/$params/$sign';
    _channel = HtmlWebSocketChannel.connect(_url); // , pingInterval: pingTime
    _isConnect = true;
    print('$_TAG -- 连接成功');
  }

  Future reopen() async {
    _channel = HtmlWebSocketChannel.connect(_url); // , pingInterval: pingTime
    _isConnect = true;
    addListen(_callback, _onDone, _onError);
    print('$_TAG -- 重新连接成功');
  }

  void addListen(VoidCallback callback, Function onDone, Function onError) {
    _callback = callback;
    _onDone = onDone;
    _onError = onError;
    if (_channel != null) {
      _channel.stream.listen((message) {
        print('$_TAG -- message>' + message);
        if (_callback != null) {
          _callback(message);
        }
      }, onError: (error) {
        print('$_TAG -- $error');
        if (_onError != null) {
          _onError();
        }
      }, onDone: () {
        _isConnect = false;
        print('$_TAG -- onDone');
        if (_onDone != null) {
          _onDone();
        }
      });
      _channel.stream.handleError((error) {
        _isConnect = false;
        print('$_TAG -- $error');
        if (_onError != null) {
          _onError();
        }
      });
    }
  }

  bool get isConnect => _isConnect;

  void ping() {
    if (_channel != null && isConnect) {
      _channel.sink.add('ping');
      print('心跳成功 -- $_TAG');
    }
  }

  void close() {
    if (_channel != null) {
      _isConnect = false;
      _channel.sink.close(status.goingAway);
      print('连接关闭成功 -- $_TAG');
    }
  }
}
