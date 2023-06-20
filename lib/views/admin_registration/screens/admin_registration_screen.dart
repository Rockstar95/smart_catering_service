import 'package:flutter/material.dart';
import 'package:smart_catering_service/backend/admin_user/admin_user_controller.dart';
import 'package:smart_catering_service/backend/navigation/navigation_arguments.dart';
import 'package:smart_catering_service/models/admin_user/data_model/admin_user_model.dart';
import 'package:smart_catering_service/models/admin_user/request_model/admin_user_update_request_model.dart';
import 'package:smart_catering_service/utils/extensions.dart';
import 'package:smart_catering_service/utils/my_safe_state.dart';
import 'package:smart_catering_service/utils/my_toast.dart';

import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../utils/my_print.dart';
import '../../common/components/common_submit_button.dart';
import '../../common/components/modal_progress_hud.dart';

class AdminRegistrationScreen extends StatefulWidget {
  static const String routeName = "/AdminRegistrationScreen";

  final AdminRegistrationScreenNavigationArguments arguments;

  const AdminRegistrationScreen({
    super.key,
    required this.arguments,
  });

  @override
  State<AdminRegistrationScreen> createState() => _AdminRegistrationScreenState();
}

class _AdminRegistrationScreenState extends State<AdminRegistrationScreen> with MySafeState {
  bool isLoading = false;

  String userId = "";
  bool isCateringEnabled = false;
  bool isPartyPlotEnabled = false;

  void updateFeatures() async {
    isLoading = true;
    mySetState();

    AdminUserUpdateRequestModel requestModel = AdminUserUpdateRequestModel(
      id: userId,
      isProfileSet: true,
      isCateringEnabled: isCateringEnabled,
      isPartyPlotEnabled: isPartyPlotEnabled,
    );

    bool isAdded = await AdminUserController().updateAdminUserDetails(requestModel: requestModel);
    MyPrint.printOnConsole("IsAdded:$isAdded");

    isLoading = false;
    mySetState();

    if (isAdded) {
      AdminUserModel adminUserModel = widget.arguments.adminUserModel;
      if (requestModel.isProfileSet != null) {
        adminUserModel.isProfileSet = requestModel.isProfileSet!;
      }
      if (requestModel.isCateringEnabled != null) {
        adminUserModel.isCateringEnabled = requestModel.isCateringEnabled!;
      }
      if (requestModel.isPartyPlotEnabled != null) {
        adminUserModel.isPartyPlotEnabled = requestModel.isPartyPlotEnabled!;
      }
      if (requestModel.updatedTime != null) {
        adminUserModel.updatedTime = requestModel.updatedTime!;
      }

      if (context.checkMounted() && context.mounted) {
        NavigationController.navigateToAdminHomeScreen(
          navigationOperationParameters: NavigationOperationParameters(
            context: context,
            navigationType: NavigationType.pushNamedAndRemoveUntil,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();

    AdminUserModel adminUserModel = widget.arguments.adminUserModel;
    userId = adminUserModel.id;
    isCateringEnabled = adminUserModel.isCateringEnabled;
    isPartyPlotEnabled = adminUserModel.isPartyPlotEnabled;
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return WillPopScope(
      onWillPop: () async {
        // return true;
        return !isLoading;
      },
      child: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "Registration",
            ),
          ),
          body: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Which facilities do you have?",
                    style: themeData.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  getCheckboxWidget(
                    text: "Catering",
                    isChecked: isCateringEnabled,
                    onChanged: (bool? newValue) {
                      isCateringEnabled = newValue ?? false;
                      mySetState();
                    },
                  ),
                  // const SizedBox(height: 20),
                  getCheckboxWidget(
                    text: "Party Plot",
                    isChecked: isPartyPlotEnabled,
                    onChanged: (bool? newValue) {
                      isPartyPlotEnabled = newValue ?? false;
                      mySetState();
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      getSubmitButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getCheckboxWidget({required String text, required bool isChecked, ValueChanged<bool?>? onChanged}) {
    return CheckboxMenuButton(
      value: isChecked,
      onChanged: onChanged,
      child: Text(
        text,
      ),
    );
  }

  Widget getSubmitButton() {
    return CommonSubmitButton(
      onTap: () {
        if (!isCateringEnabled && !isPartyPlotEnabled) {
          MyToast.showError(context: context, msg: "You must have at least one facility");
          return;
        }

        updateFeatures();
      },
      text: "Submit",
      fontSize: 14,
      horizontalPadding: 20,
      verticalPadding: 10,
    );
  }
}
