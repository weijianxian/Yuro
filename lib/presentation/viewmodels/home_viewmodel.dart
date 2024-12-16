import 'package:asmrapp/presentation/viewmodels/base/paginated_works_viewmodel.dart';
import 'package:asmrapp/data/services/api_service.dart';
import 'package:get_it/get_it.dart';

class HomeViewModel extends PaginatedWorksViewModel {
  HomeViewModel() : super(GetIt.I<ApiService>());

  @override
  String get pageName => '主页';

  @override
  Future<WorksResponse> fetchPage(int page) {
    return apiService.getWorks(page: page);
  }
}
