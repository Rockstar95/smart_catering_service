import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/navigation/navigation_controller.dart';
import 'package:smart_catering_service/backend/navigation/navigation_operation_parameters.dart';
import 'package:smart_catering_service/backend/navigation/navigation_type.dart';
import 'package:smart_catering_service/models/admin_user/data_model/admin_user_model.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/authentication/authentication_provider.dart';
import '../../../configs/styles.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_safe_state.dart';
import '../../common/components/common_text.dart';
import '../../common/components/modal_progress_hud.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({Key? key}) : super(key: key);

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> with MySafeState {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Consumer<AuthenticationProvider>(
      builder: (BuildContext context, AuthenticationProvider authenticationProvider, Widget? child) {
        AdminUserModel? adminUserModel = authenticationProvider.adminUserModel.get();

        return Scaffold(
          backgroundColor: Styles.themeBgColor,
          appBar: AppBar(
            title: const Text("Profile"),
          ),
          body: ModalProgressHUD(
            inAsyncCall: isLoading,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if (adminUserModel?.isCateringEnabled ?? false)
                    singleOption1(
                      iconData: Icons.emoji_food_beverage_rounded,
                      option: "Catering",
                      ontap: () async {
                        NavigationController.navigateToAddEditAdminCateringScreen(
                          navigationOperationParameters: NavigationOperationParameters(
                            context: context,
                            navigationType: NavigationType.pushNamed,
                          ),
                        );
                      },
                    ),
                  if (adminUserModel?.isPartyPlotEnabled ?? false)
                    singleOption1(
                      iconData: Icons.business,
                      option: "Party Plot",
                      ontap: () async {},
                    ),
                  adminUserModel != null
                      ? singleOption1(
                          iconData: Icons.logout,
                          option: "Logout",
                          ontap: () async {
                            MyPrint.printOnConsole("logout");
                            isLoading = true;
                            mySetState();

                            await AuthenticationController(authenticationProvider: authenticationProvider).logout(isShowConfirmationDialog: true, isNavigateToLogin: true);
                            MyPrint.printOnConsole("Logged Out");

                            isLoading = false;
                            mySetState();
                          },
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget singleOption({
    IconData? iconData,
    String? iconPath,
    required String option,
    String? screen,
    Object? argument,
    double? imageIconSize,
    Function()? onTap,
  }) {
    return InkWell(
      onTap: () async {
        if (onTap != null) {
          onTap();
        }
        if (screen != null && screen.isNotEmpty) {
          Navigator.pushNamed(context, screen, arguments: argument);
        }
      },
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            if (iconData != null)
              Icon(
                iconData,
                size: 22,
                color: themeData.colorScheme.onBackground,
              ),
            if (iconPath != null && iconPath.isNotEmpty)
              Image.asset(
                iconPath,
                width: imageIconSize ?? 20,
                //color: themeData.colorScheme.onBackground,
              ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 16),
                child: Text(
                  option,
                  style: themeData.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 22,
              color: themeData.colorScheme.onBackground,
            ),
          ],
        ),
      ),
    );
  }

  Widget singleOption1({
    required IconData iconData,
    required String option,
    Function? ontap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: InkWell(
        onTap: () async {
          if (ontap != null) ontap();

          // AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.profile_menu_clicked, parameters: {AnalyticsParameters.event_value: option});
        },
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 0),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: themeData.colorScheme.onPrimary,
            border: Border.all(color: themeData.primaryColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                iconData,
                size: 21,
                color: themeData.colorScheme.onBackground,
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12),
                  child: CommonText(
                    text: option,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: themeData.colorScheme.onBackground,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
