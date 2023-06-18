import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/my_print.dart';
import '../../views/authentication/screens/login_screen.dart';
import '../../views/common/screens/splashscreen.dart';
import '../../views/courses/screens/course_details_screen.dart';
import '../../views/homescreen/screens/homescreen.dart';
import 'navigation_arguments.dart';
import 'navigation_operation.dart';
import 'navigation_operation_parameters.dart';

class NavigationController {
  static NavigationController? _instance;
  static String chatRoomId = "";
  static bool isNoInternetScreenShown = false;
  static bool isFirst = true;

  factory NavigationController() {
    _instance ??= NavigationController._();
    return _instance!;
  }

  NavigationController._();

  static final GlobalKey<NavigatorState> mainScreenNavigator = GlobalKey<NavigatorState>();

  static bool isUserProfileTabInitialized = false;

  static bool checkDataAndNavigateToSplashScreen() {
    MyPrint.printOnConsole("checkDataAndNavigateToSplashScreen called, isFirst:$isFirst");

    if (isFirst) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        isFirst = false;
        Navigator.pushNamedAndRemoveUntil(mainScreenNavigator.currentContext!, SplashScreen.routeName, (route) => false);
      });
    }

    return isFirst;
  }

  static Route? onMainAppAdminGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("onAdminMainGeneratedRoutes called for ${settings.name} with arguments:${settings.arguments}");

    // if(navigationCount == 2 && Uri.base.hasFragment && Uri.base.fragment != "/") {
    //   return null;
    // }

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }
    /*if(!["/", SplashScreen.routeName].contains(settings.name)) {
      if(NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }
    else {
      if(!kIsWeb) {
        if(isFirst) {
          isFirst = false;
        }
      }
    }*/

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const SplashScreen();
          break;
        }
      case SplashScreen.routeName:
        {
          page = const SplashScreen();
          break;
        }
      case LoginScreen.routeName:
        {
          page = parseLoginScreen(settings: settings);
          break;
        }
      case HomeScreen.routeName:
        {
          page = parseHomeScreen(settings: settings);
          break;
        }
      case CourseDetailsScreen.routeName:
        {
          page = parseCourseDetailsScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  static Route? onMainAppUserGeneratedRoutes(RouteSettings settings) {
    MyPrint.printOnConsole("onAdminMainGeneratedRoutes called for ${settings.name} with arguments:${settings.arguments}");

    // if(navigationCount == 2 && Uri.base.hasFragment && Uri.base.fragment != "/") {
    //   return null;
    // }

    if (kIsWeb) {
      if (!["/", SplashScreen.routeName].contains(settings.name) && NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }
    /*if(!["/", SplashScreen.routeName].contains(settings.name)) {
      if(NavigationController.checkDataAndNavigateToSplashScreen()) {
        return null;
      }
    }
    else {
      if(!kIsWeb) {
        if(isFirst) {
          isFirst = false;
        }
      }
    }*/

    MyPrint.printOnConsole("First Page:$isFirst");
    Widget? page;

    switch (settings.name) {
      case "/":
        {
          page = const SplashScreen();
          break;
        }
      case SplashScreen.routeName:
        {
          page = const SplashScreen();
          break;
        }
      case LoginScreen.routeName:
        {
          page = parseLoginScreen(settings: settings);
          break;
        }
      case HomeScreen.routeName:
        {
          page = parseHomeScreen(settings: settings);
          break;
        }
      case CourseDetailsScreen.routeName:
        {
          page = parseCourseDetailsScreen(settings: settings);
          break;
        }
    }

    if (page != null) {
      return PageRouteBuilder(
        pageBuilder: (c, a1, a2) => page!,
        //transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
        transitionsBuilder: (c, anim, a2, child) => SizeTransition(sizeFactor: anim, child: child),
        transitionDuration: const Duration(milliseconds: 0),
        settings: settings,
      );
    }
    return null;
  }

  //region Parse Page From RouteSettings
  static Widget? parseLoginScreen({required RouteSettings settings}) {
    return const LoginScreen();
  }

  static Widget? parseHomeScreen({required RouteSettings settings}) {
    return const HomeScreen();
  }

  static Widget? parseCourseDetailsScreen({required RouteSettings settings}) {
    dynamic argument = settings.arguments;
    if (argument is CourseDetailsScreenNavigationArguments) {
      return CourseDetailsScreen(arguments: argument);
    } else {
      return null;
    }
  }

  //endregion

  //region Navigation Methods
  static Future<dynamic> navigateToLoginScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: LoginScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToHomeScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: HomeScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToCourseDetailsScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required CourseDetailsScreenNavigationArguments arguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: CourseDetailsScreen.routeName,
        arguments: arguments,
      ),
    );
  }
  //endregion
}
