import 'package:smart_catering_service/backend/course/course_provider.dart';
import 'package:smart_catering_service/views/courses/screens/all_courses_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

import '../../../backend/home_screen/home_screen_provider.dart';
import '../../../configs/styles.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_safe_state.dart';
import '../../profile/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "/HomeScreen";

  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin, MySafeState {
  int _currentIndex = 0;
  late TabController _tabController;

  late HomeScreenProvider homeScreenProvider;

  Widget? allCoursesListScreenWidget, myCoursesListScreenWidget, profileWidget;

  //region Tab Handling
  _handleTabSelection() {
    FocusScope.of(context).requestFocus(FocusNode());

    MyPrint.printOnConsole("_handleTabSelection called");
    _currentIndex = _tabController.index;
    homeScreenProvider.homeTabIndex.set(value: _tabController.index, isNotify: true);

    //if(_currentIndex == 1 && Provider.of<ProductProvider>(context, listen: false).searchedProductsList == null) ProductController().getProducts(context, true, withnotifying: false);
  }

  _handleTabSelectionInAnimation() {
    final aniValue = _tabController.animation?.value ?? 0;
    //MyPrint.printOnConsole("Animation Value:$aniValue");
    //MyPrint.printOnConsole("Current Value:$_currentIndex");

    double diff = aniValue - _currentIndex;

    //MyPrint.printOnConsole("Current Before:$_currentIndex");
    if (aniValue - _currentIndex > 0.5) {
      _currentIndex++;
    } else if (aniValue - _currentIndex < -0.5) {
      _currentIndex--;
    }
    //MyPrint.printOnConsole("Current After:$_currentIndex");

    //if(_currentIndex == 1 && Provider.of<ProductProvider>(context, listen: false).searchedProductsList == null) ProductController().getProducts(context, true, withnotifying: false);

    //For Direct Tap
    if (diff != 1 && diff != -1 && diff != 2 && diff != -2 && diff != 3 && diff != -3) {
      mySetState();
    }
  }

  //endregion

  late CourseProvider courseProvider;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
    _tabController.animation?.addListener(_handleTabSelectionInAnimation);

    courseProvider = context.read<CourseProvider>();
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Consumer(
      builder: (BuildContext context, HomeScreenProvider homeScreenProvider, Widget? child) {
        this.homeScreenProvider = homeScreenProvider;

        return Container(
          color: themeData.colorScheme.background,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            bottomNavigationBar: getBottomBar(homeScreenProvider),
            body: TabBarView(
              controller: _tabController,
              children: <Widget>[
                getAllCoursesListScreen(),
                getMyCoursesListScreen(),
                getUserProfile(),
              ],
            ),
          ),
        );
      },
    );
  }

  //region Bottom Navigation Section
  Widget getBottomBar(HomeScreenProvider homeScreenProvider) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: themeData.cardTheme.shadowColor!.withAlpha(40),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        notchMargin: 5,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: themeData.bottomAppBarTheme.color,
            boxShadow: [
              BoxShadow(
                color: themeData.cardTheme.shadowColor!.withAlpha(40),
                blurRadius: 3,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: TabBar(
            onTap: (int index) {},
            controller: _tabController,
            indicator: UnderlineTabIndicator(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color:Styles.themeBlue, width: 8.0),
              insets: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 58.0),
            ),
            labelColor: Styles.themeBlue,
            unselectedLabelColor: themeData.colorScheme.onBackground.withOpacity(0.4),
            labelPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            labelStyle: (themeData.textTheme.bodySmall ?? const TextStyle()).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
            tabs:  const <Widget>[
              Tab(
                icon: Icon(
                  Icons.video_library_outlined,
                  size: 20,
                ),
                iconMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                text: "All Courses",
              ),
              Tab(
                icon: Icon(Icons.play_lesson_outlined,size: 20),
                iconMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                text: "My Courses",
              ),
              Tab(
                icon: Icon(
                  MdiIcons.account,
                  size: 20,
                ),
                iconMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                text: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBottomBarButton({String? text, required int index, required IconData iconData}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconData,
          size: 20,
          color: themeData.colorScheme.primary,
        ),
        index != _currentIndex
            ? Text(
                text ?? "",
                style: themeData.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: themeData.colorScheme.primary,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  //endregion

  Widget getAllCoursesListScreen() {
    allCoursesListScreenWidget ??= AllCoursesListScreen(courseProvider: courseProvider);

    return allCoursesListScreenWidget!;
  }

  Widget getMyCoursesListScreen() {
    myCoursesListScreenWidget ??= MyCoursesListScreen(courseProvider: courseProvider);

    return myCoursesListScreenWidget!;
  }

  Widget getUserProfile() {
    profileWidget ??= const ProfileScreen();

    return profileWidget!;
  }
}
