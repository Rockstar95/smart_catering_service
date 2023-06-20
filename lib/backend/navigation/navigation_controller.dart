import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smart_catering_service/views/catering/screens/add_edit_admin_catering_package_screen.dart';

import '../../utils/my_print.dart';
import '../../views/admin_registration/screens/admin_registration_screen.dart';
import '../../views/authentication/screens/login_screen.dart';
import '../../views/catering/screens/add_edit_admin_catering_screen.dart';
import '../../views/common/screens/splashscreen.dart';
import '../../views/homescreen/screens/admin_homescreen.dart';
import '../../views/homescreen/screens/user_homescreen.dart';
import '../../views/profile/screens/user_edit_profile_screen.dart';
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
    MyPrint.printOnConsole("onMainAppAdminGeneratedRoutes called for ${settings.name} with arguments:${settings.arguments}");

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
      case AdminRegistrationScreen.routeName:
        {
          page = parseAdminRegistrationScreen(settings: settings);
          break;
        }
      case AdminHomeScreen.routeName:
        {
          page = parseAdminHomeScreen(settings: settings);
          break;
        }
      case AddEditAdminCateringScreen.routeName:
        {
          page = parseAddEditAdminCateringScreen(settings: settings);
          break;
        }
      case AddEditAdminCateringPackageScreen.routeName:
        {
          page = parseAddEditAdminCateringPackageScreen(settings: settings);
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
    MyPrint.printOnConsole("onMainAppUserGeneratedRoutes called for ${settings.name} with arguments:${settings.arguments}");

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
      case UserEditProfileScreen.routeName:
        {
          page = parseUserEditProfileScreen(settings: settings);
          break;
        }
      case UserHomeScreen.routeName:
        {
          page = parseUserHomeScreen(settings: settings);
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

  static Widget? parseUserEditProfileScreen({required RouteSettings settings}) {
    dynamic argument = settings.arguments;
    if (argument is UserEditProfileScreenNavigationArguments) {
      return UserEditProfileScreen(arguments: argument);
    } else {
      return null;
    }
  }

  static Widget? parseAdminRegistrationScreen({required RouteSettings settings}) {
    dynamic argument = settings.arguments;
    if (argument is! AdminRegistrationScreenNavigationArguments) return null;
    return AdminRegistrationScreen(arguments: argument);
  }

  static Widget? parseAdminHomeScreen({required RouteSettings settings}) {
    return const AdminHomeScreen();
  }

  static Widget? parseUserHomeScreen({required RouteSettings settings}) {
    return const UserHomeScreen();
  }

  static Widget? parseAddEditAdminCateringScreen({required RouteSettings settings}) {
    return const AddEditAdminCateringScreen();
  }

  static Widget? parseAddEditAdminCateringPackageScreen({required RouteSettings settings}) {
    dynamic argument = settings.arguments;
    if (argument is! AddEditAdminCateringPackageScreenNavigationArguments) return null;
    return AddEditAdminCateringPackageScreen(arguments: argument);
  }

  //endregion

  //region Navigation Methods
  static Future<dynamic> navigateToLoginScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: LoginScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToUserEditProfileScreen({required NavigationOperationParameters navigationOperationParameters, required UserEditProfileScreenNavigationArguments arguments}) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: UserEditProfileScreen.routeName,
        arguments: arguments,
      ),
    );
  }

  static Future<dynamic> navigateToAdminRegistrationScreen({required NavigationOperationParameters navigationOperationParameters, required AdminRegistrationScreenNavigationArguments arguments}) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AdminRegistrationScreen.routeName,
        arguments: arguments,
      ),
    );
  }

  static Future<dynamic> navigateToAdminHomeScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: AdminHomeScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToUserHomeScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: UserHomeScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToAddEditAdminCateringScreen({required NavigationOperationParameters navigationOperationParameters}) {
    return NavigationOperation.navigate(
        navigationOperationParameters: navigationOperationParameters.copyWith(
      routeName: AddEditAdminCateringScreen.routeName,
    ));
  }

  static Future<dynamic> navigateToAddEditAdminCateringPackageScreen({
    required NavigationOperationParameters navigationOperationParameters,
    required AddEditAdminCateringPackageScreenNavigationArguments arguments,
  }) {
    return NavigationOperation.navigate(
      navigationOperationParameters: navigationOperationParameters.copyWith(
        routeName: AddEditAdminCateringPackageScreen.routeName,
        arguments: arguments,
      ),
    );
  }
//endregion
}
