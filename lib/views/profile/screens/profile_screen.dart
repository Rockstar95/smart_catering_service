import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/authentication_controller.dart';
import '../../../backend/authentication/authentication_provider.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../configs/styles.dart';
import '../../../models/user/data_model/user_model.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_safe_state.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_text.dart';
import '../../common/components/modal_progress_hud.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with MySafeState {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Consumer<AuthenticationProvider>(
      builder: (BuildContext context, AuthenticationProvider authenticationProvider, Widget? child) {
        UserModel? userModel = authenticationProvider.userModel.get();

        return Scaffold(
          backgroundColor: Styles.themeBgColor,
          appBar: AppBar(
            title: const Text(
              "Profile"
            ),
          ),
          body: ModalProgressHUD(
            inAsyncCall: isLoading,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  getProfileDetails(userModel),
                  Column(
                    children: <Widget>[
                      singleOption1(
                        iconData: Icons.edit_outlined,
                        option: "Edit",
                        ontap: () async {
                          if (userModel != null) {
                            await NavigationController.navigateToUserEditProfileScreen(
                              navigationOperationParameters: NavigationOperationParameters(
                                context: context,
                                navigationType: NavigationType.pushNamed,
                              ),
                              arguments: UserEditProfileScreenNavigationArguments(userModel: userModel),
                            );

                            mySetState();
                          }
                        },
                      ),
                      userModel != null
                          ? singleOption1(
                              iconData: Icons.logout,
                              option: "Logout",
                              ontap: () async {
                                MyPrint.printOnConsole("logout");
                                isLoading = true;
                                mySetState();

                                await AuthenticationController(authenticationProvider: authenticationProvider)
                                    .logout(isShowConfirmationDialog: true, isNavigateToLogin: true);
                                MyPrint.printOnConsole("Logged Out");

                                isLoading = false;
                                mySetState();
                              },
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getProfileDetails(UserModel? userModel) {
    /*String userAccountDetails = "";
    if ((userModel?.mobileNumber ?? "").isNotEmpty) {
      userAccountDetails = (userModel?.mobileNumber ?? "");
    }

    ImageProvider<Object> image;
    if ((userModel?.imageUrl ?? "").isNotEmpty) {
      image = CachedNetworkImageProvider(
        userModel!.imageUrl,
      );
    } else {
      image = const AssetImage("./assets/logo2.png");
    }*/

    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  getProfileAvatar(imageUrl: userModel?.imageUrl ?? ''),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CommonText(
                      text: userModel?.name ?? 'Not Given',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Row(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.phone_outlined, color: Colors.grey, size: 16),
                              SizedBox(width: 8),
                              CommonText(
                                text: 'Email Id',
                                color: Colors.grey,
                                fontSize: 13,
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          CommonText(
                            text: userModel?.email ?? 'Not Given',
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                    /*const VerticalDivider(width: 1,color: Colors.grey,thickness: 1,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.video_library_outlined,color: Colors.grey,size: 16),
                              const SizedBox(width: 8,),
                              CommonText(text:'Course taken for',color: Colors.grey,fontSize: 13, )

                            ],
                          ),
                          const SizedBox(height: 5,),
                          CommonText(text:userModel?.preference ?? 'Not Given',
                            fontSize: 12, fontWeight: FontWeight.normal,),
                        ],
                      ),
                    ),*/
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Divider(
          color: Colors.grey.withOpacity(.4),
          height: 5,
          thickness: 1,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget getProfileAvatar({required String imageUrl}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.withOpacity(.06), width: 3),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Styles.white, width: 3),
        ),
        child: imageUrl.isEmpty
            ? Image.asset(
                'assets/images/male.png',
                height: 50,
                width: 50,
              )
            : CommonCachedNetworkImage(
                borderRadius: 100,
                imageUrl: imageUrl,
                height: 50,
                width: 50,
              ),
      ),
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
    return InkWell(
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
    );
  }
}
