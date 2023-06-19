import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:smart_catering_service/utils/extensions.dart';

import '../../../backend/common/data_controller.dart';
import '../../../backend/navigation/navigation_arguments.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../backend/user/user_controller.dart';
import '../../../configs/styles.dart';
import '../../../models/user/data_model/user_model.dart';
import '../../../models/user/request_model/profile_update_request_model.dart';
import '../../../utils/my_print.dart';
import '../../../utils/my_safe_state.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_submit_button.dart';
import '../../common/components/common_text.dart';
import '../../common/components/modal_progress_hud.dart';
import '../componants/profile_text_form_field.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = "/EditProfileScreen";

  final EditProfileScreenNavigationArguments arguments;

  const EditProfileScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with MySafeState {
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Uint8List? profileImageBytes;
  String? profileImageUrl;
  List<String> filesToDelete = [];

  String userId = "";
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();

  Future getBussinessImage() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty && (result.files.first.path?.isNotEmpty ?? false)) {
      PlatformFile platformFile = result.files.first;

      CroppedFile? newImage = await ImageCropper().cropImage(
        compressFormat: ImageCompressFormat.png,
        sourcePath: platformFile.path!,
        cropStyle: CropStyle.rectangle,
        aspectRatioPresets: [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: themeData.colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (newImage == null) {
        MyPrint.printOnConsole("image file null");
      } else {
        MyPrint.printOnConsole("image file not null");
        MyPrint.printOnConsole("Cropped Image Path:${newImage.path}");

        profileImageBytes = await newImage.readAsBytes();
        mySetState();
      }
    }
  }

  Future<List<String>> uploadImages({required String bussinessId, required List<Uint8List> images}) async {
    List<String> downloadUrls = [];

    String tempUserId = userId;

    if (tempUserId.isEmpty) {
      tempUserId = "user";
    }

    await Future.wait(
      images.map((Uint8List bytes) async {
        // String fileName = file.path.substring(file.path.lastIndexOf("/") + 1);
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
        Reference reference = FirebaseStorage.instance.ref().child("profile").child(tempUserId).child(bussinessId).child(fileName);
        UploadTask uploadTask = reference.putData(bytes);

        TaskSnapshot snapshot = await uploadTask.then((snapshot) => snapshot);
        if (snapshot.state == TaskState.success) {
          final String downloadUrl = await snapshot.ref.getDownloadURL();
          downloadUrls.add(downloadUrl);

          /*final String downloadUrl = "https://storage.googleapis.com/${Firebase.app().options.storageBucket}/profile/$tempUserId/$bussinessId/$fileName";
          downloadUrls.add(downloadUrl);*/

          MyPrint.printOnConsole('$fileName Upload success');
        } else {
          MyPrint.printOnConsole('Error from image repo uploading $fileName: ${snapshot.toString()}');
          //throw ('This file is not an image');
        }
      }),
      eagerError: true,
      cleanUp: (_) {
        MyPrint.printOnConsole('eager cleaned up');
      },
    );

    return downloadUrls;
  }

  void editProfile() async {
    isLoading = true;
    mySetState();

    String imageUrl;

    MyPrint.printOnConsole("filesToDelete:$filesToDelete");
    if (filesToDelete.isNotEmpty) {
      await DataController.deleteImages(images: filesToDelete);
    }

    if (profileImageUrl != null && profileImageUrl!.isNotEmpty) {
      imageUrl = profileImageUrl!;
    } else {
      if (profileImageBytes != null) {
        List<String> images = await uploadImages(bussinessId: userId, images: [profileImageBytes!]);
        imageUrl = images.isNotEmpty ? images.first : "";
        // imageUrl = await CloudinaryManager().uploadBussinessImage(bussinessId: model.id, image: bussinessImageFile!);
      } else {
        imageUrl = "";
      }
    }

    ProfileUpdateRequestModel requestModel = ProfileUpdateRequestModel(
      id: userId,
      name: nameController.text.trim(),
      mobile: mobileController.text.trim(),
      imageUrl: imageUrl,
      // preference: userPreference,
    );

    bool isAdded = await UserController().updateProfileDetails(requestModel: requestModel);
    MyPrint.printOnConsole("IsAdded:$isAdded");

    isLoading = false;
    mySetState();

    if (isAdded) {
      UserModel userModel = widget.arguments.userModel;
      if (requestModel.name != null) {
        userModel.name = requestModel.name!;
      }
      if (requestModel.mobile != null) {
        userModel.mobile = requestModel.mobile!;
      }
      if (requestModel.imageUrl != null) {
        userModel.imageUrl = requestModel.imageUrl!;
      }
      if (requestModel.updatedTime != null) {
        userModel.updatedTime = requestModel.updatedTime!;
      }

      // AnalyticsController().fireEvent(analyticEvent: AnalyticsEvent.business_event, parameters: {AnalyticsParameters.event_value : "Edited"});
      if (context.checkMounted() && context.mounted) {
        if (widget.arguments.isSignUp) {
          NavigationController.navigateToHomeScreen(
            navigationOperationParameters: NavigationOperationParameters(
              context: context,
              navigationType: NavigationType.pushNamedAndRemoveUntil,
            ),
          );
        } else {
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    UserModel userModel = widget.arguments.userModel;

    userId = userModel.id;
    nameController.text = userModel.name;
    mobileController.text = userModel.mobile;

    profileImageUrl = userModel.imageUrl;
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
            title: Text(
              widget.arguments.isSignUp ? "Profile" : "Edit Profile",
            ),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  widget.arguments.isSignUp ? getTopComponentForSignUp() : getTopComponentForEditProfile(),
                  const SizedBox(height: 20),
                  getBasicDetails(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getTopComponentForSignUp() {
    return Column(
      children: [
        getSignupTopInfo(),
      ],
    );
  }

  Widget getSignupTopInfo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          color: Styles.themeBlue,
          width: double.infinity,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 2),
              CommonText(
                text: 'Create an Account !',
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 10),
              CommonText(
                text: 'Please provide your details, and let us customize your experience!',
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w100,
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
        Stack(
          children: [
            Container(
              height: 60,
              width: double.maxFinite,
              decoration: const BoxDecoration(color: Styles.themeBlue),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getProfileAvatar(),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget getTopComponentForEditProfile() {
    return Column(
      children: [
        const SizedBox(height: 30),
        getProfileAvatar(),
        const SizedBox(height: 45),
        Container(
          width: double.maxFinite,
          color: Colors.grey.shade300,
          height: 2,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget getEditButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Styles.themeEditOrange.withOpacity(.05),
            border: Border.all(color: Styles.themeEditOrange.withOpacity(.25), width: 1.5),
            borderRadius: BorderRadius.circular(60),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(Icons.edit, color: Styles.themeEditOrange.withOpacity(.6), size: 18),
              const SizedBox(
                width: 5,
              ),
              CommonText(
                text: 'Edit',
                color: Styles.themeEditOrange.withOpacity(.6),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: .6,
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget getProfileAvatar() {
    Widget imageWidget;
    Widget imageActionWidget;

    if (profileImageBytes != null) {
      imageWidget = Image.memory(
        profileImageBytes!,
        height: 105,
        width: 105,
      );
      imageActionWidget = InkWell(
        onTap: () {
          profileImageBytes = null;
          mySetState();
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1)),
          child: const Icon(Icons.close, color: Styles.bgSideMenu, size: 14),
        ),
      );
    } else if (profileImageUrl.checkNotEmpty) {
      imageWidget = CommonCachedNetworkImage(
        borderRadius: 100,
        imageUrl: profileImageUrl!,
        height: 105,
        width: 105,
      );
      imageActionWidget = InkWell(
        onTap: () {
          filesToDelete.add(profileImageUrl!);
          profileImageUrl = null;
          mySetState();
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1)),
          child: const Icon(Icons.close, color: Styles.bgSideMenu, size: 14),
        ),
      );
    } else {
      imageWidget = Image.asset(
        'assets/images/male.png',
        height: 105,
        width: 105,
      );
      imageActionWidget = InkWell(
        onTap: () {
          getBussinessImage();
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey, width: 1)),
          child: const Icon(Icons.edit, color: Styles.bgSideMenu, size: 14),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withOpacity(.15), width: 3),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Styles.white, width: 4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: imageWidget,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 5,
          child: imageActionWidget,
        ),
      ],
    );
  }

  Widget getBasicDetails() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          getNameTextField(),
          const SizedBox(height: 20),
          getMobileTextField(),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonSubmitButton(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());

                  bool isFormValid = _formKey.currentState?.validate() ?? false;

                  if (isFormValid) {
                    //MyPrint.printOnConsole("Valid");
                    editProfile();
                  }
                  else {
                    //MyPrint.printOnConsole("Not Valid");
                    /*if(!((bussinessImageUrl != null && bussinessImageUrl.isNotEmpty) || bussinessImageFile != null)) {
                MyToast.showError("Select Bussiness Image", context);
              }*/
                  }
                },
                text: widget.arguments.isSignUp ? 'Submit' : 'Save',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget getImageWidget() {
    if (profileImageBytes == null && (profileImageUrl == null || profileImageUrl!.isEmpty)) {
      return Column(
        children: [
          InkWell(
            onTap: () {
              getBussinessImage();
            },
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: themeData.colorScheme.onBackground),
              ),
              child: const Icon(
                Icons.cloud_upload,
                size: 40,
              ),
            ),
          ),
          Text(
            "Add Your Profile Pic",
            style: themeData.textTheme.bodyMedium,
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      );
    } else {
      if (profileImageBytes != null) {
        return Container(
          width: 100,
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: ClipRRect(
                  //borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: Image.memory(profileImageBytes!),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    profileImageBytes = null;
                    mySetState();
                  },
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeData.colorScheme.primary,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else {
        return Container(
          width: 100,
          margin: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 10, right: 10),
                child: ClipRRect(
                  //borderRadius: BorderRadius.all(Radius.circular(16)),
                  child: CommonCachedNetworkImage(
                    imageUrl: profileImageUrl!,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: InkWell(
                  onTap: () {
                    filesToDelete.add(profileImageUrl!);
                    profileImageUrl = null;
                    mySetState();
                  },
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeData.colorScheme.primary,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  Widget getNameTextField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyCommonTextField(
          controller: nameController,
          hintText: 'Enter your full name',
          prefix: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Icon(
              Icons.person_outline,
              color: Styles.themeBlue,
              size: 21,
            ),
          ),
          onChanged: (String value) {
            mySetState();
          },
          validator: (val) {
            if (val == null || val.isEmpty) {
              return "Username cannot be empty";
            } else {
              return null;
            }
          },
        ),
        const SizedBox(height: 5),
        if(nameController.text.isEmpty) Text(
          "* Enter Full Name (ex. Rahul Ramesh Roy)",
          style: themeData.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: themeData.textTheme.labelSmall!.color?.withOpacity(0.6),
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }

  Widget getMobileTextField() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MyCommonTextField(
          controller: mobileController,
          hintText: 'Enter your mobile number',
          prefix: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10.0),
            child: const Icon(
              Icons.person_outline,
              color: Styles.themeBlue,
              size: 21,
            ),
          ),
          onChanged: (String value) {
            mySetState();
          },
          textInputFormatter: [
            FilteringTextInputFormatter.deny('.'),
            LengthLimitingTextInputFormatter(10),
          ],
          validator: (val) {
            if (val == null || val.isEmpty) {
              return "Username cannot be empty";
            } else {
              return null;
            }
          },
        ),
      ],
    );
  }

  Widget getEditBussinessButton() {
    return InkWell(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());

        bool isFormValid = _formKey.currentState?.validate() ?? false;

        if (isFormValid) {
          //MyPrint.printOnConsole("Valid");
          editProfile();
        } else {
          //MyPrint.printOnConsole("Not Valid");
          /*if(!((bussinessImageUrl != null && bussinessImageUrl.isNotEmpty) || bussinessImageFile != null)) {
            MyToast.showError("Select Bussiness Image", context);
          }*/
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 60,
          vertical: 5,
        ),
        decoration: BoxDecoration(
          color: themeData.colorScheme.primary,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          widget.arguments.isSignUp ? "Sign Up" : "Edit",
          style: themeData.textTheme.bodyLarge?.copyWith(
            color: themeData.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
