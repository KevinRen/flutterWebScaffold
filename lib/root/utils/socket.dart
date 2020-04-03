import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

typedef VoidCallback = void Function(String message);

class SocketUtil {
  static const String _TAG = "###SocketUtil###";

  static const Duration pingTime = Duration(seconds: 2);

  IOWebSocketChannel _channel;
  String _url;
  bool _isConnect = false;
  VoidCallback _callback;
  Function _onDone;
  Function _onError;

  Future open(String url, String param1, String param2) async {
    final timeSpan = DateTime.now().millisecondsSinceEpoch;
    final sign = _encryptWebSocketSign(param1, param2, timeSpan);
    if (_channel != null) {
      _channel.sink.close();
    }
    _url = url + "/" + param1 + "/" + param2 + "/" + timeSpan.toString() + "/" + sign;
    _channel = IOWebSocketChannel.connect(_url, pingInterval: pingTime);
    _isConnect = true;
    print('$_TAG -- 连接成功');
  }

  Future reopen() async {
    _channel = IOWebSocketChannel.connect(_url, pingInterval: pingTime);
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

  String _encryptWebSocketSign(String param1, String param2, timeSpan) {
    final key = 'syyy^&*syyy!@#Sy';
    final secretKey = 'syyy1q2w3e';
    final str = secretKey + '|' + param1 + '|' + param2 + '|' + timeSpan.toString();

    final convertContent = _md5(str);
    final encrypter = Encrypter(AES(Key.fromUtf8(key), mode: AESMode.ecb, padding: 'PKCS7'));
    final aecText = _md5(encrypter.encrypt(convertContent).base16);

    return aecText.toString();
  }

  /// md5 加密
  static String _md5(String data) {
    var content = new Utf8Encoder().convert(data);
    var digest = md5.convert(content);
    return digest.toString();
  }
}
