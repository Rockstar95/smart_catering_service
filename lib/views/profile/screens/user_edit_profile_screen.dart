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
import '../../common/components/modal_progress_hud.dart';
import '../componants/profile_text_form_field.dart';

class UserEditProfileScreen extends StatefulWidget {
  static const String routeName = "/UserEditProfileScreen";

  final UserEditProfileScreenNavigationArguments arguments;

  const UserEditProfileScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<UserEditProfileScreen> createState() => _UserEditProfileScreenState();
}

class _UserEditProfileScreenState extends State<UserEditProfileScreen> with MySafeState {
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

  Future<List<String>> uploadImages({required String userId, required List<Uint8List> images}) async {
    List<String> downloadUrls = [];

    String tempUserId = userId;

    if (tempUserId.isEmpty) {
      tempUserId = "user";
    }

    await Future.wait(
      images.map((Uint8List bytes) async {
        // String fileName = file.path.substring(file.path.lastIndexOf("/") + 1);
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
        Reference reference = FirebaseStorage.instance.ref().child("users").child(tempUserId).child("profile").child(fileName);
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
        List<String> images = await uploadImages(userId: userId, images: [profileImageBytes!]);
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
          NavigationController.navigateToUserHomeScreen(
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
                  const SizedBox(height: 30),
                  getProfileAvatar(),
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
              getSubmitButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget getNameTextField() {
    return MyCommonTextField(
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
    );
  }

  Widget getMobileTextField() {
    return MyCommonTextField(
      controller: mobileController,
      hintText: 'Enter your mobile number',
      prefix: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: const Icon(
          Icons.phone,
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
    );
  }

  Widget getSubmitButton() {
    return CommonSubmitButton(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());

        bool isFormValid = _formKey.currentState?.validate() ?? false;

        if (isFormValid) {
          //MyPrint.printOnConsole("Valid");
          editProfile();
        } else {
          //MyPrint.printOnConsole("Not Valid");
        }
      },
      text: widget.arguments.isSignUp ? "Sign Up" : "Edit",
    );
  }
}
