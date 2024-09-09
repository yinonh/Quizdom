import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server.g.dart';

@Riverpod(keepAlive: true)
Dio dio(DioRef ref) {
  final dio = Dio(
    BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        baseUrl: 'https://opentdb.com/'),
  );
  dio.interceptors.add(DioInterceptor());
  return dio;
}

class DioInterceptor implements Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    log('🌍 Sending network request: ${options.baseUrl}${options.path}');
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // log('❌ Dio Error!: ${err.message}');
    // log('❌ Url: ${err.requestOptions.uri}');
    // log('❌ ${err.stackTrace}');
    // log('❌ Response Error: ${err.response?.data}');
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // log('⬅️ Received network response');
    // log('${response.statusCode != 200 ? '❌ ${response.statusCode} ❌' : '✅ 200 ✅'} ${response.requestOptions.baseUrl}${response.requestOptions.path}');
    // log('Query params: ${response.requestOptions.queryParameters}');
    // log('Full Response: ${response.toString()}');
    // log('Response Data: ${response.data}');
    // log('-------------------------');
    return handler.next(response);
  }
}
