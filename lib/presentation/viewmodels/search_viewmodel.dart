import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/models/works/pagination.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:asmrapp/utils/logger.dart';

class SearchViewModel extends ChangeNotifier {
  final _apiService = GetIt.I<ApiService>();
  
  List<Work> _works = [];
  List<Work> get works => _works;
  
  String _keyword = '';
  String get keyword => _keyword;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _error;
  String? get error => _error;

  Pagination? _pagination;
  int get totalPages => _pagination?.totalCount != null && _pagination?.pageSize != null 
      ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
      : 1;
  int _currentPage = 1;
  int get currentPage => _currentPage;

  /// 执行搜索
  Future<void> search(String keyword, {int page = 1}) async {
    if (keyword.isEmpty) return;
    
    _keyword = keyword;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('搜索关键词: $keyword, 页码: $page');
      final response = await _apiService.searchWorks(
        keyword: keyword,
        page: page,
      );
      
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = page;
      AppLogger.info('搜索成功: ${response.works.length}个结果');
    } catch (e) {
      AppLogger.error('搜索失败', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载指定页
  Future<void> loadPage(int page) async {
    if (_keyword.isEmpty) return;
    await search(_keyword, page: page);
  }

  /// 清空搜索结果
  void clear() {
    _works = [];
    _keyword = '';
    _error = null;
    _pagination = null;
    _currentPage = 1;
    notifyListeners();
  }
} 