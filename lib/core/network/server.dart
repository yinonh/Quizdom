import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'server.g.dart';

final logger = Logger(
  printer: PrettyPrinter(),
);

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
    logger.i('🌍 Sending network request: ${options.baseUrl}${options.path}');
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e("Dio Error!: ${err.message}");
    logger.e("Url: ${err.requestOptions.uri}");
    logger.e("${err.stackTrace}");
    logger.e("Response Error: ${err.response?.data}");
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 200) {
      logger.i(
          "${response.requestOptions.baseUrl}${response.requestOptions.path}");
    } else {
      logger.e(
          "${response.requestOptions.baseUrl}${response.requestOptions.path}");
    }
    logger.i("Query params: ${response.requestOptions.queryParameters}");
    logger.i("Full Response: ${response.toString()}");
    logger.i("Response Data: ${response.data}");
    return handler.next(response);
  }
}
