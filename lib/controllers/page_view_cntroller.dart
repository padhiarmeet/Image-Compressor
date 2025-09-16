    import 'package:get/get.dart';
    import 'package:flutter/material.dart';

    class PageViewController extends GetxController {
      final PageController pageController = PageController();
      var currentPageIndex = 0.obs;

      @override
      void onClose() {
         pageController.dispose();
        super.onClose();
      }

      void onPageChanged(int index) {
        currentPageIndex.value = index;
      }

      void goToPage(int index) {
        pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    }