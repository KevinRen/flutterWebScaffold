import 'package:flutter/cupertino.dart';

enum DataType { String, Map, Int, List, Bool }
enum ContentType { FormData, Json }

class RequestBuilder {
  final BuildContext context;
  final String url;
  final String token;
  final Map data;
  final DataType dataType;
  final Map<String, dynamic> headerSetting;

  RequestBuilder({
    @required this.context,
    @required this.url,
    this.dataType = DataType.Map,
    this.token,
    this.data,
    this.headerSetting,
  });
}