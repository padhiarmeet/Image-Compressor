import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeTabController extends GetxController with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  final RxInt selectedIndex = 0.obs;
  final List<String> tabTitles = ['Compress', 'Advanced'];

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: tabTitles.length, vsync: this);
    tabController.addListener(() {
      selectedIndex.value = tabController.index;
    });
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    tabController.animateTo(index);
    selectedIndex.value = index;
  }

  IconData getTabIcon(int index) {
    switch (index) {
      case 0:
        return Icons.compress;
      case 1:
        return Icons.tune;
      default:
        return Icons.compress;
    }
  }

  String getTabTitle(int index) {
    if (index >= 0 && index < tabTitles.length) {
      return tabTitles[index];
    }
    return tabTitles[0];
  }

  bool isTabSelected(int index) {
    return selectedIndex.value == index;
  }

  String get currentTabTitle => getTabTitle(selectedIndex.value);

  IconData get currentTabIcon => getTabIcon(selectedIndex.value);
}