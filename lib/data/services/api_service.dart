import 'package:dio/dio.dart';
import '../models/work.dart';

class ApiService {
  static const String baseUrl = 'https://api.asmr.one/api';
  final Dio _dio;

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
    },
  ));

  Future<List<Work>> getWorks({
    String order = 'create_date',
    String sort = 'desc',
    int page = 1,
    bool subtitle = true,
  }) async {
    try {
      final response = await _dio.get(
        '/works',
        queryParameters: {
          'order': order,
          'sort': sort,
          'page': page,
          'subtitle': subtitle ? 1 : 0,
        },
      );

      final data = response.data;
      final List<dynamic> works = data['works'];
      return works.map((json) => Work.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('网络连接超时');
      case DioExceptionType.badResponse:
        return Exception('服务器错误 (${e.response?.statusCode})');
      case DioExceptionType.cancel:
        return Exception('请求被取消');
      default:
        return Exception('网络错误: ${e.message}');
    }
  }
} 