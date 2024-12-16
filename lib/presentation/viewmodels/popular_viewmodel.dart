import 'package:asmrapp/presentation/viewmodels/base/paginated_works_viewmodel.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:get_it/get_it.dart';

class PopularViewModel extends PaginatedWorksViewModel {
  PopularViewModel() : super(GetIt.I<ApiService>());

  @override
  String get pageName => '热门列表';

  @override
  Future<WorksResponse> fetchPage(int page) {
    return apiService.getPopular(page: page);
  }

  // 保持原有的便捷方法
  Future<void> loadPopular({bool refresh = false}) => refresh ? this.refresh() : loadPage(1);
} 