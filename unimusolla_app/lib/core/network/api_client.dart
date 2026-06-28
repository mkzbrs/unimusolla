import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/api_constants.dart';
import '../storage/session_storage.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this._sessionStorage)
    : dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 30),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _sessionStorage.readToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final SessionStorage _sessionStorage;
  final Dio dio;

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    try {
      final response = await dio.get(path, queryParameters: query);
      return _decode(response.data);
    } on DioException catch (error) {
      throw ApiException(_messageFrom(error));
    }
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? data}) async {
    try {
      final response = await dio.post(
        path,
        data: data ?? {},
        options: Options(contentType: Headers.jsonContentType),
      );
      return _decode(response.data);
    } on DioException catch (error) {
      throw ApiException(_messageFrom(error));
    }
  }

  Future<dynamic> postJson(String path, {Map<String, dynamic>? data}) =>
      post(path, data: data);

  Future<dynamic> upload(
    String path, {
    required List<XFile> files,
    String field = 'images',
    Map<String, dynamic>? data,
  }) async {
    try {
      final form = FormData.fromMap(data ?? {});
      for (final file in files) {
        form.files.add(
          MapEntry(
            '$field[]',
            await MultipartFile.fromFile(file.path, filename: file.name),
          ),
        );
      }
      final response = await dio.post(path, data: form);
      return _decode(response.data);
    } on DioException catch (error) {
      throw ApiException(_messageFrom(error));
    }
  }

  dynamic _decode(dynamic data) {
    if (data is String) {
      final trimmed = data.trim();
      if (trimmed.isEmpty) return {};
      try {
        return jsonDecode(trimmed);
      } catch (_) {
        return data;
      }
    }
    return data;
  }

  String _messageFrom(DioException error) {
    final data = _decode(error.response?.data);
    if (data is Map) {
      for (final key in ['message', 'error', 'detail']) {
        final value = data[key];
        if (value != null && value.toString().trim().isNotEmpty)
          return value.toString();
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'Connection timed out. Please try again.';
    }
    return error.message ?? 'Something went wrong. Please try again.';
  }
}
