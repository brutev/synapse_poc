import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../error/error_mapper.dart';

class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? Dio() {
    _dio
      ..options.baseUrl = AppConfig.baseUrl
      ..options.headers = <String, String>{'Content-Type': 'application/json'};

    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  final Dio _dio;

  Future<Response<dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      return await _dio.post<dynamic>(path, data: data);
    } on DioException catch (exception) {
      throw ErrorMapper.mapDioException(exception);
    }
  }
}
