import 'package:asmrapp/data/models/work.dart';

class HomeViewModel {
  // 获取作品列表
  List<Work> getWorks() {
    // TODO: 实现实际的数据获取逻辑
    return Work.mockData;
  }

  // 处理作品点击
  void onWorkTap(Work work) {
    // TODO: 实现作品点击逻辑
  }

  // 处理搜索
  void onSearch() {
    // TODO: 实现搜索逻辑
  }
} 