import 'package:dio/dio.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/models/works/pagination.dart';
import 'package:asmrapp/utils/logger.dart';

class WorksResponse {
  final List<Work> works;
  final Pagination pagination;

  WorksResponse({required this.works, required this.pagination});
}

class ApiService {
  final Dio _dio;
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api.asmr.one/api',
  ));

  /// 获取作品文件列表
  Future<Files> getWorkFiles(String workId) async {
    try {
      final response = await _dio.get('/tracks/$workId', queryParameters: {
        'v': '1',
      });
      
      if (response.statusCode == 200) {
        final filesData = {
          'type': 'root',
          'title': 'Root',
          'children': response.data,
        };

        return Files.fromJson(filesData);
      }
      
      throw Exception('获取文件列表失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// 获取作品列表
  Future<WorksResponse> getWorks({int page = 1}) async {
    try {
      final response = await _dio.get('/works', queryParameters: {
        'page': page,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> works = response.data['works'] ?? [];
        final pagination = Pagination.fromJson(response.data['pagination']);
        
        return WorksResponse(
          works: works.map((work) => Work.fromJson(work)).toList(),
          pagination: pagination,
        );
      }
      
      throw Exception('获取作品列表失败: ${response.statusCode}');
    } on DioException catch (e) {
      AppLogger.error('网络请求失败', e, e.stackTrace);
      throw Exception('网络请求失败: ${e.message}');
    } catch (e, stackTrace) {
      AppLogger.error('解析数据失败', e, stackTrace);
      throw Exception('解析数据失败: $e');
    }
  }

  /// 搜索作品
  Future<WorksResponse> searchWorks({
    required String keyword,
    int page = 1,
    String order = 'create_date',
    String sort = 'desc',
    int subtitle = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/search/${Uri.encodeComponent(keyword)}',
        queryParameters: {
          'page': page,
          'order': order,
          'sort': sort,
          'subtitle': subtitle,
          'includeTranslationWorks': true,
        },
      );

      if (response.statusCode == 200) {
        AppLogger.debug('搜索返回数据: ${response.data}');
        
        final works = (response.data['works'] as List)
            .map((work) => Work.fromJson(work))
            .toList();

        final pagination = Pagination.fromJson(response.data['pagination']);

        return WorksResponse(
          works: works,
          pagination: pagination,
        );
      }

      throw Exception('搜索失败: ${response.statusCode}');
    } catch (e) {
      throw Exception('搜索请求失败: $e');
    }
  }
}
