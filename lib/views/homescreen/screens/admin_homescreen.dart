import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/catering/catering_provider.dart';

import '../../../backend/home_screen/home_screen_provider.dart';
import '../../../configs/styles.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_safe_state.dart';
import '../../profile/screens/profile_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  static const String routeName = "/AdminHomeScreen";

  const AdminHomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> with SingleTickerProviderStateMixin, MySafeState {
  int _currentIndex = 0;
  late TabController _tabController;

  late HomeScreenProvider homeScreenProvider;

  Widget? cateringScreenWidget, myCoursesListScreenWidget, profileWidget;

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

  late CateringProvider cateringProvider;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(_handleTabSelection);
    _tabController.animation?.addListener(_handleTabSelectionInAnimation);

    cateringProvider = context.read<CateringProvider>();
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
                getCateringScreen(),
                getPartyPlotScreen(),
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
                  Icons.emoji_food_beverage_rounded,
                  size: 20,
                ),
                iconMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                text: "Catering",
              ),
              Tab(
                icon: Icon(Icons.business,size: 20),
                iconMargin: EdgeInsets.symmetric(horizontal: 0, vertical: 2),
                text: "Party Plot",
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

  Widget getCateringScreen() {
    cateringScreenWidget ??= const Center(
      child: Text("Enquiry"),
    );

    return cateringScreenWidget!;
  }

  Widget getPartyPlotScreen() {
    myCoursesListScreenWidget ??= const Center(
      child: Text("Enquiry"),
    );

    return myCoursesListScreenWidget!;
  }

  Widget getUserProfile() {
    profileWidget ??= const ProfileScreen();

    return profileWidget!;
  }
}
