import 'package:flutter/cupertino.dart';

class RequestBuilder {
  final String url;
  final String token;
  final Map data;
  final Map<String, dynamic> headerSetting;

  RequestBuilder({
    @required this.url,
    this.token,
    this.data,
    this.headerSetting,
  });
}