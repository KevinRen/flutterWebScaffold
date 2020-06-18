import 'package:flutter/material.dart';
import 'utils/http.dart';
import 'comm.dart';
import 'appRouter.dart';

enum Env {
  dev,
  qa,
  uat,
  product
}

class RootConfig {
  final String baseUrl;
  final Interceptor interceptor;
  final ContentType contentType;
  final Map<dynamic, RouteBuild> routers;

  RootConfig({
    @required this.routers,
    @required this.baseUrl,
    this.interceptor,
    this.contentType,
  });
}

class AppEnv {
  static Env env = Env.dev;

  static void setAppConfig(RootConfig config) {
    HttpRequest.baseUrl = config.baseUrl;
    AppRouter.routers = config.routers;
    if (config.interceptor != null) HttpRequest.interceptor = config.interceptor;
    if (config.contentType != null) HttpRequest.contentType = config.contentType;
  }
}