import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/authentication/authentication_provider.dart';
import 'package:smart_catering_service/backend/common/app_controller.dart';
import 'package:smart_catering_service/backend/navigation/navigation_arguments.dart';
import 'package:smart_catering_service/backend/navigation/navigation_controller.dart';
import 'package:smart_catering_service/backend/navigation/navigation_operation_parameters.dart';
import 'package:smart_catering_service/backend/navigation/navigation_type.dart';
import 'package:smart_catering_service/configs/constants.dart';
import 'package:smart_catering_service/utils/extensions.dart';
import 'package:smart_catering_service/utils/my_print.dart';
import 'package:smart_catering_service/utils/my_safe_state.dart';
import 'package:smart_catering_service/views/common/components/modal_progress_hud.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../models/admin_user/data_model/admin_user_model.dart';
import '../../../models/user/data_model/user_model.dart';

class LoginScreen extends StatefulWidget {
  static BuildContext? context;
  static const String routeName = "/LoginScreen";

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with MySafeState {
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController? mobileController;

  late AuthenticationProvider authenticationProvider;
  late AuthenticationController authenticationController;

  void signInWithGoogle() async {
    if (isLoading) return;

    isLoading = true;
    mySetState();

    bool isLoggedIn = await authenticationController.signInWithGoogle(context: context);
    MyPrint.printOnConsole("isLoggedIn:$isLoggedIn");

    isLoading = false;
    mySetState();

    if (isLoggedIn) {
      await authenticationController.startUserSubscription();

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
  }

  @override
  void initState() {
    super.initState();

    mobileController = TextEditingController();

    authenticationProvider = context.read<AuthenticationProvider>();
    authenticationController = AuthenticationController(authenticationProvider: authenticationProvider);
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.only(top: 0, left: 20, right: 20),
          child: Center(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    getLogo(),
                    getLoginText(),
                    const SizedBox(height: 50),
                    getLoginWithGoogleButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getLogo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 34),
      width: 150,
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(AppAssets.logo),
      ),
    );
  }

  Widget getLoginText() {
    return InkWell(
      onTap: () async {},
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16),
        child: const Center(
          child: Text(
            "Log In",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget getLoginWithGoogleButton() {
    return InkWell(
      onTap: () {
        signInWithGoogle();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeData.colorScheme.onPrimary,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          border: Border.all(color: themeData.primaryColor),
        ),
        child: Row(
          children: [
            Image.asset(AppAssets.googleLogo, height: 26),
            Expanded(
              child: Center(
                child: Text(
                  "Login With Google",
                  style: themeData.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
