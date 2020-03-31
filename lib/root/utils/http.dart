import 'package:dio/dio.dart';
import 'dart:convert';

class HttpRequest {
  static Dio _dio;
  static String baseUrl;
  static const int _CONNECT_TIMEOUT = 10000;
  static const int _RECEIVE_TIMEOUT = 30000;

  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  static Map<String, CancelToken> tokens = Map();

  static _cancel(String token) {
    if (token.isNotEmpty && tokens[token] != null) {
      CancelToken cancelToken = tokens[token];
      if (!cancelToken.isCancelled) {
        cancelToken.cancel('cancelled');
        tokens.remove(token);
      }
    }
  }

  static Future request(String url, {String token, Map data, List<Map<String, dynamic>> headerSetting}) async {
    data = data == null ? Map() : data;

    Dio dio = _createInstance();
    if (headerSetting != null) {
      dio.options.headers = _headers(headerSetting);
    }

    CancelToken cancelToken = CancelToken();
    if (token != null && token.isNotEmpty) tokens[token] = cancelToken;
    Response response = await dio.post(url, data: FormData.fromMap(Map.unmodifiable(data)), cancelToken: cancelToken);

    var result = response.data;
    if (result is String) {
      result = jsonDecode(result);
    }

    return result;
  }

  static Map<String, dynamic> _headers(List<Map<String, dynamic>> headerSetting) {
    Map<String, dynamic> _headers = Map();
    headerSetting.forEach((element) {
      element.forEach((key, value) {
        _headers[key] = value;
      });
    });
    return _headers;
  }

  /// 创建 dio 实例对象
  static Dio _createInstance() {
    if (_dio == null) {
      /// 全局属性：请求前缀、连接超时时间、响应超时时间
      BaseOptions options = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: _CONNECT_TIMEOUT,
        receiveTimeout: _RECEIVE_TIMEOUT,
      );

      _dio = new Dio(options);

      /// 设置拦截器
      _dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) {
        return options;
      }, onResponse: (Response response) {
        return response;
      }, onError: (DioError error) {
        throw error;
      }));
    }

    return _dio;
  }
}