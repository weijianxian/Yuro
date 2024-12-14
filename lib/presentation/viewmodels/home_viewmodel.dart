import 'package:asmrapp/data/models/works/pagination.dart';
import 'package:flutter/foundation.dart';
import 'package:asmrapp/data/models/works/work.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:get_it/get_it.dart';

class HomeViewModel extends ChangeNotifier {
  final ApiService _apiService;
  List<Work> _works = [];
  bool _isLoading = false;
  String? _error;
  Pagination? _pagination;
  int _currentPage = 1;

  HomeViewModel() : _apiService = GetIt.I<ApiService>();

  List<Work> get works => _works;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int? get totalPages =>
      _pagination?.totalCount != null && _pagination?.pageSize != null
          ? (_pagination!.totalCount! / _pagination!.pageSize!).ceil()
          : null;

  /// 加载指定页面的数据
  Future<void> loadPage(int page) async {
    if (_isLoading) return;
    if (page < 1 || (totalPages != null && page > totalPages!)) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // AppLogger.info('加载作品列表: 第$page页');
      final response = await _apiService.getWorks(page: page);
      _works = response.works;
      _pagination = response.pagination;
      _currentPage = page;
      AppLogger.info('第$page页作品列表加载成功: ${response.works.length}个作品');
    } catch (e) {
      AppLogger.error('加载作品列表失败', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载作品列表(用于初始加载和刷新)
  Future<void> loadWorks({bool refresh = false}) async {
    await loadPage(1);
  }

  void onWorkTap(Work work) {
    // TODO: 实现品点击逻辑
  }

  void onSearch() {
    // TODO: 实现搜索逻辑
  }
}
