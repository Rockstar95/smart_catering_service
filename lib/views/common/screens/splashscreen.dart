import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/common/app_controller.dart';
import 'package:smart_catering_service/configs/constants.dart';
import 'package:smart_catering_service/models/admin_user/data_model/admin_user_model.dart';
import 'package:smart_catering_service/models/user/data_model/user_model.dart';
import 'package:smart_catering_service/utils/extensions.dart';

import '../../../backend/admin_user/admin_user_controller.dart';
import '../../../backend/admin_user/admin_user_provider.dart';
import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/authentication/authentication_provider.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_utils.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = "/SplashScreen";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late ThemeData themeData;

  Future<void> checkLogin() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("SplashScreen().checkLogin() called", tag: tag);

    NavigationController.isFirst = false;

    AuthenticationProvider authenticationProvider = context.read<AuthenticationProvider>();
    AuthenticationController authenticationController = AuthenticationController(authenticationProvider: authenticationProvider);

    bool isUserLoggedIn = await authenticationController.isUserLoggedIn();
    MyPrint.printOnConsole("isUserLoggedIn:$isUserLoggedIn", tag: tag);

    if (!isUserLoggedIn) {
      if (context.checkMounted() && context.mounted) {
        NavigationController.navigateToLoginScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ),
        );
        return;
      }
    }

    bool isExist = await authenticationController.checkUserWithIdExistOrNotAndIfNotExistThenCreate(userId: authenticationProvider.userId.get());
    MyPrint.printOnConsole("isExist:$isExist", tag: tag);

    await authenticationController.startUserSubscription();

    if (context.checkMounted() && context.mounted) {
      if(AppController.isAdminApp) {
        AdminUserController adminUserController = AdminUserController(
          authenticationProvider: authenticationProvider,
          adminUserProvider: context.read<AdminUserProvider>(),
        );

        await Future.wait([
          adminUserController.initializeCateringModel(cateringId: authenticationProvider.userId.get()),
          adminUserController.initializePartyPlotModel(partyPlotId: authenticationProvider.userId.get()),
        ]);
      }
    }

    if (context.checkMounted() && context.mounted) {
      if(AppController.isAdminApp) {
        AdminUserModel? adminUserModel = authenticationProvider.adminUserModel.get();
        if(adminUserModel == null) {
          NavigationController.navigateToLoginScreen(
            navigationOperationParameters: NavigationOperationParameters(
              context: context,
              navigationType: NavigationType.pushNamedAndRemoveUntil,
            ),
          );
        }
        else if(!adminUserModel.isProfileSet) {
          NavigationController.navigateToAdminRegistrationScreen(
            navigationOperationParameters: NavigationOperationParameters(
              context: context,
              navigationType: NavigationType.pushNamedAndRemoveUntil,
            ),
            arguments: AdminRegistrationScreenNavigationArguments(adminUserModel: adminUserModel),
          );
        }
        else {
          NavigationController.navigateToAdminHomeScreen(
            navigationOperationParameters: NavigationOperationParameters(
              context: context,
              navigationType: NavigationType.pushNamedAndRemoveUntil,
            ),
          );
        }
      }
      else {
        UserModel? userModel = authenticationProvider.userModel.get();
        if(userModel == null) {
          NavigationController.navigateToLoginScreen(
            navigationOperationParameters: NavigationOperationParameters(
              context: context,
              navigationType: NavigationType.pushNamedAndRemoveUntil,
            ),
          );
        }
        else if(userModel.name.isEmpty) {
          NavigationController.navigateToUserEditProfileScreen(
            navigationOperationParameters: NavigationOperationParameters(
              context: context,
              navigationType: NavigationType.pushNamedAndRemoveUntil,
            ),
            arguments: UserEditProfileScreenNavigationArguments(
              userModel: userModel,
              isSignUp: true,
            ),
          );
        }
        else {
          NavigationController.navigateToUserHomeScreen(
            navigationOperationParameters: NavigationOperationParameters(
              context: context,
              navigationType: NavigationType.pushNamedAndRemoveUntil,
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      checkLogin();
    });
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);

    return Container(
      color: themeData.colorScheme.background,
      child: SafeArea(
        child: Scaffold(
          body: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: SizedBox.square(
                            dimension: context.sizeData.width * 0.7,
                            child: Image.asset(
                              AppAssets.logo,
                              width: 120,
                              height: 120,
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: LoadingAnimationWidget.inkDrop(color: themeData.primaryColor, size: 40),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                // padding: const EdgeInsets.all(10.0),
                child: const Text("Made with ❤ by Friendly It Solution.",style: TextStyle(fontSize: 11), textAlign: TextAlign.center,),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
