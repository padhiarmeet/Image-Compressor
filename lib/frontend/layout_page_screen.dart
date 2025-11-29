import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_compressor/controllers/themeController.dart';
import 'package:image_compressor/frontend/formate_change_screen.dart';
import 'package:image_compressor/frontend/homePage.dart';
import 'package:image_compressor/frontend/pdf_screen.dart';
import '../controllers/page_view_cntroller.dart';
import 'history_screen.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> with TickerProviderStateMixin {
  bool isDarkMode = true;

  ThemeController themeController = Get.find<ThemeController>();
  PageViewController pageViewController = Get.find<PageViewController>();


  @override
  Widget build(BuildContext context) {

    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,

      //region APP BAR
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: AppBar(
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surface.withOpacity(0.8),
              elevation: 0,
              centerTitle: false,
              title: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      child: Image.asset('assets/app_icon/app_iconV3.png')
                    ),
                    const SizedBox(width: 12),
                    Obx(

                      () {
                        String title = pageViewController.currentPageIndex == 0
                            ? 'Compressor'
                            : pageViewController.currentPageIndex == 1
                            ? 'History'
                            : pageViewController.currentPageIndex == 2
                            ? 'PDF Maker'
                            : 'Change Format';
                        return Text(
                          title,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(
                          () => IconButton(
                        onPressed: () {
                          themeController.toggleTheme();
                        },
                        icon: Icon(
                          themeController.isDarkMode
                              ? Icons.wb_sunny_rounded
                              : Icons.nightlight_round,
                          key: ValueKey(themeController.isDarkMode),
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      //endregion
      body: Column(
        children: [
          Expanded(
              child: PageView(
                controller: pageViewController.pageController,
                onPageChanged: pageViewController.onPageChanged,
                children: [
                  Homepage(),
                  HistoryScreen(),
                  PdfScreen(),
                  ChangeFormatScreen(),
                ],
              )
          )
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  //region METHOD FOR DISPLAYING BOTTOM NAVIGATION BAR
  Widget _buildBottomNavigationBar(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaY: 15, sigmaX: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Obx(
            ()=> BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.shifting,
              currentIndex: pageViewController.currentPageIndex.value,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              onTap: (value) {
                pageViewController.goToPage(value);
              },
              items: const [
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.home_rounded),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.history_rounded),
                  icon: FaIcon(FontAwesomeIcons.clockRotateLeft,size: 20,),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  activeIcon: FaIcon(FontAwesomeIcons.solidFilePdf,size: 18,),
                  icon: FaIcon(FontAwesomeIcons.filePdf,size: 20,),
                  label: 'Convert to PDF',
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.edit_document),
                  icon: FaIcon(FontAwesomeIcons.filePen,size: 20,),
                  label: 'Change Format',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
//endregion
}