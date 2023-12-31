import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/catering/catering_provider.dart';

import '../backend/admin_user/admin_user_provider.dart';
import '../backend/app_theme/app_theme_provider.dart';
import '../backend/authentication/authentication_provider.dart';
import '../backend/connection/connection_provider.dart';
import '../backend/home_screen/home_screen_provider.dart';
import '../backend/navigation/navigation_controller.dart';
import '../utils/my_print.dart';

class MyAppAdmin extends StatelessWidget {
  const MyAppAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MyPrint.printOnConsole("MyAppAdmin Build Called");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppThemeProvider>(create: (_) => AppThemeProvider(), lazy: false),
        ChangeNotifierProvider<AuthenticationProvider>(create: (_) => AuthenticationProvider(), lazy: false),
        ChangeNotifierProvider<ConnectionProvider>(create: (_) => ConnectionProvider(), lazy: false),
        ChangeNotifierProvider<CateringProvider>(create: (_) => CateringProvider(), lazy: false),
        ChangeNotifierProvider<HomeScreenProvider>(create: (_) => HomeScreenProvider(), lazy: false),
        ChangeNotifierProvider<AdminUserProvider>(create: (_) => AdminUserProvider(), lazy: false),
      ],
      child: const MainAppAdmin(),
    );
  }
}

class MainAppAdmin extends StatelessWidget {
  const MainAppAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    MyPrint.printOnConsole("MainAppAdmin Build Called");

    return OverlaySupport.global(
      child: Consumer<AppThemeProvider>(
        builder: (BuildContext context, AppThemeProvider appThemeProvider, Widget? child) {
          //MyPrint.printOnConsole("ThemeMode:${appThemeProvider.themeMode}");

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationController.mainScreenNavigator,
            title: "SCS Admin App",
            // showPerformanceOverlay: true,
            theme: appThemeProvider.getThemeData(),
            onGenerateRoute: NavigationController.onMainAppAdminGeneratedRoutes,
          );
        },
      ),
    );
  }
}
