import 'package:asmrapp/data/models/works/pagination.dart';
import 'package:flutter/foundation.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:asmrapp/utils/logger.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final Map<int, List<Work>> _pageWorks = {}; // 存储每一页的作品
  bool _isLoading = false;
  String? _error;
  Pagination? _pagination;
  
  // 当前显示的页码
  int _displayPage = 1;
  
  List<Work> get works {
    final allWorks = <Work>[];
    // 按页码顺序合并所有页面的数据
    for (var i = 1; i <= _displayPage; i++) {
      if (_pageWorks.containsKey(i)) {
        allWorks.addAll(_pageWorks[i]!);
      }
    }
    return allWorks;
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage {
    if (_scrollPosition <= 0) return 1;
    
    // 计算当前视口中心位置显示的作品
    final viewportHeight = 200.0; // 假设视口高度
    final centerPosition = _scrollPosition + (viewportHeight / 2);
    final centerIndex = centerPosition ~/ _itemHeight;
    
    if (centerIndex >= works.length) return _displayPage;
    
    // 找到这个作品属于哪一页
    final centerWork = works[centerIndex];
    for (var page = 1; page <= _displayPage; page++) {
      if (_pageWorks[page]?.contains(centerWork) ?? false) {
        return page;
      }
    }
    
    return 1;
  }

  int? get totalPages => _pagination?.totalCount != null && _pagination?.pageSize != null 
      ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
      : null;

  Future<void> loadWorks({bool refresh = false}) async {
    if (refresh) {
      AppLogger.info('刷新作品列表');
      _pageWorks.clear();
      _pagination = null;
      _displayPage = 1;
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
      _pageWorks[nextPage] = response.works;
      _pagination = response.pagination;
      _displayPage = nextPage;
      
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
    if (_pageWorks.containsKey(page)) {
      _displayPage = page;
      notifyListeners();
    } else {
      // 如果该页面还未加载，则加载它
      loadPage(page);
    }
  }

  // 加载指定页面
  Future<void> loadPage(int page) async {
    if (_isLoading || _pageWorks.containsKey(page)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('加载作品列表: 第$page页');
      final response = await _apiService.getWorks(page: page);
      _pageWorks[page] = response.works;
      _pagination = response.pagination;
      _displayPage = page;
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
    // TODO: 实现作品点击逻辑
  }

  void onSearch() {
    // TODO: 实现搜索逻辑
  }

  double _scrollPosition = 0.0;
  final double _itemHeight = 200.0;

  void updateScrollPosition(double position) {
    _scrollPosition = position;
    notifyListeners();
  }
}
