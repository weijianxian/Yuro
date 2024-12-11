import 'package:asmrapp/data/models/works/pagination.dart';
import 'package:flutter/foundation.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:asmrapp/utils/logger.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Work> _works = []; // 改为只存储当前页数据
  bool _isLoading = false;
  String? _error;
  Pagination? _pagination;
  
  int _currentPage = 1; // 重命名为更清晰的名称
  
  List<Work> get works => _works; // 简化getter直接返回当前页数据

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;

  int? get totalPages => _pagination?.totalCount != null && _pagination?.pageSize != null 
      ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
      : null;

  Future<void> loadWorks({bool refresh = false}) async {
    if (refresh) {
      AppLogger.info('刷新作品列表');
      _works.clear();
      _pagination = null;
      _currentPage = 1;
    }

    if (_isLoading) return;
    
    // 如果已经加载完所有页面，就不再加载
    if (_pagination != null && 
        _pagination!.currentPage! * _pagination!.pageSize! >= (_pagination!.totalCount ?? 0)) {
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nextPage = refresh ? 1 : (_pagination?.currentPage ?? 0) + 1;
      AppLogger.info('加载作品列表: 第$nextPage页');
      
      final response = await _apiService.getWorks(page: nextPage);
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = nextPage;
      
      AppLogger.info('作品列表加载成功: ${response.works.length}个作品');
    } catch (e) {
      AppLogger.error('加载作品列表失败', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 切换显示页面
  void setDisplayPage(int page) {
    if (_works.isNotEmpty && page > 0 && page <= _works.length) {
      _currentPage = page;
      notifyListeners();
    } else {
      // 如果该页面还未加载，则加载它
      loadPage(page);
    }
  }

  // 加载指定页面
  Future<void> loadPage(int page) async {
    if (_isLoading || _works.isNotEmpty && page > 0 && page <= _works.length) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('加载作品列表: 第$page页');
      final response = await _apiService.getWorks(page: page);
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = page;
      AppLogger.info('作品列表加载成功: ${response.works.length}个作品');
    } catch (e) {
      AppLogger.error('加载作品列表失败', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onWorkTap(Work work) {
    // TODO: 实现品点击逻辑
  }

  void onSearch() {
    // TODO: 实现搜索逻辑
  }

  // 跳转到指定页面
  Future<void> jumpToPage(int page) async {
    if (page < 1 || page > (totalPages ?? 1)) return;
    
    AppLogger.info('跳转到第$page页');
    
    // 清空现有数据
    _works.clear();
    _currentPage = page;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getWorks(page: page);
      _works = response.works;
      _pagination = response.pagination;
      AppLogger.info('页面加载成功: ${response.works.length}个作品');
    } catch (e) {
      AppLogger.error('加载页面失败', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
