import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import '../comm.dart';

typedef Interceptor(BuildContext context, Map data, DataType dataType);

class HttpRequest {
  static Dio _dio;
  static String baseUrl;
  static Interceptor interceptor;
  static ContentType contentType = ContentType.FormData;
  static const int _CONNECT_TIMEOUT = 10000;
  static const int _RECEIVE_TIMEOUT = 30000;

  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  static Map<String, CancelToken> tokens = Map();

  static Future request(RequestBuilder requestBuilder) async {
    Map data = requestBuilder.data == null ? Map() : requestBuilder.data;

    Dio dio = _createInstance();
    if (requestBuilder.headerSetting != null) {
      dio.options.headers = _headers(requestBuilder.headerSetting);
    }

    getDataByContentType(data) {
      switch(contentType) {
        case ContentType.FormData: return FormData.fromMap(Map.unmodifiable(data));
        case ContentType.Json: return data;
      }
    }

    CancelToken cancelToken = CancelToken();
    if (requestBuilder.token != null && requestBuilder.token.isNotEmpty) tokens[requestBuilder.token] = cancelToken;
    Response response = await dio.post(requestBuilder.url, data: getDataByContentType(data), cancelToken: cancelToken);

    var result = response.data;
    if (result is String) {
      result = jsonDecode(result);
    }

    return interceptor == null ? result : interceptor(requestBuilder.context, result, requestBuilder.dataType);
  }

  static Map<String, dynamic> _headers(Map<String, dynamic> headerSetting) {
    Map<String, dynamic> _headers = Map();
    headerSetting.forEach((key, value) => _headers[key] = value);
    return _headers;
  }

  /// 创建 dio 实例对象
  static Dio _createInstance() {
    if (_dio == null) {
      /// 全局属性：请求前缀、连接超时时间、响应超时时间
      BaseOptions options = BaseOptions(
        baseUrl: baseUrl,
        contentType: contentType == ContentType.FormData ? Headers.formUrlEncodedContentType : Headers.jsonContentType,
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
