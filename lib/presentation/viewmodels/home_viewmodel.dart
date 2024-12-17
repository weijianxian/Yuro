import 'dart:convert';
import 'package:asmrapp/presentation/viewmodels/base/paginated_works_viewmodel.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:get_it/get_it.dart';
import 'package:asmrapp/presentation/models/filter_state.dart';
import 'package:asmrapp/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeViewModel extends PaginatedWorksViewModel {
  static const String _filterStateKey = 'home_filter_state';
  
  bool _filterPanelExpanded = false;
  bool get filterPanelExpanded => _filterPanelExpanded;

  FilterState _filterState = const FilterState();
  FilterState get filterState => _filterState;

  HomeViewModel() : super(GetIt.I<ApiService>());

  @override
  Future<void> onInit() async {
    await _loadFilterState();
  }

  Future<void> _loadFilterState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_filterStateKey);
      if (jsonStr != null) {
        _filterState = FilterState.fromJson(jsonDecode(jsonStr));
        notifyListeners();
      }
    } catch (e) {
      AppLogger.error('加载筛选状态失败', e);
    }
  }

  Future<void> _saveFilterState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_filterStateKey, jsonEncode(_filterState.toJson()));
    } catch (e) {
      AppLogger.error('保存筛选状态失败', e);
    }
  }

  void toggleFilterPanel() {
    _filterPanelExpanded = !_filterPanelExpanded;
    notifyListeners();
  }

  void updateSubtitle(bool value) {
    _filterState = _filterState.copyWith(hasSubtitle: value);
    _saveFilterState();
    notifyListeners();
    refresh();
  }

  void updateOrderField(String value) {
    // 如果切换到随机排序，强制设置为降序
    final newState = _filterState.copyWith(
      orderField: value,
      isDescending: value == 'random' ? true : _filterState.isDescending,
    );
    _filterState = newState;
    _saveFilterState();
    notifyListeners();
    refresh();
  }

  void updateSortDirection(bool isDescending) {
    if (_filterState.orderField == 'random') return;
    _filterState = _filterState.copyWith(isDescending: isDescending);
    _saveFilterState();
    notifyListeners();
    refresh();
  }

  @override
  String get pageName => '主页';

  @override
  Future<WorksResponse> fetchPage(int page) {
    return apiService.getWorks(
      page: page,
      hasSubtitle: _filterState.hasSubtitle,
      order: _filterState.orderField,
      sort: _filterState.sortValue,
    );
  }

  @override
  void dispose() {
    _saveFilterState();
    super.dispose();
  }
}
