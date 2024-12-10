import 'package:dio/dio.dart';
import 'package:asmrapp/data/models/files/files.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/utils/logger.dart';

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
  Future<List<Work>> getWorks({int page = 1}) async {
    try {
      final response = await _dio.get('/works', queryParameters: {
        'page': page,
      });
      
      if (response.statusCode == 200) {
        final List<dynamic> works = response.data['works'] ?? [];
        return works.map((work) => Work.fromJson(work)).toList();
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
}
