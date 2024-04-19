import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/admin_user/admin_user_controller.dart';
import 'package:smart_catering_service/backend/admin_user/admin_user_provider.dart';
import 'package:smart_catering_service/backend/authentication/authentication_provider.dart';
import 'package:smart_catering_service/backend/navigation/navigation_arguments.dart';
import 'package:smart_catering_service/backend/navigation/navigation_controller.dart';
import 'package:smart_catering_service/backend/navigation/navigation_operation_parameters.dart';
import 'package:smart_catering_service/backend/navigation/navigation_type.dart';
import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';
import 'package:smart_catering_service/models/catering/data_model/catering_package_model.dart';
import 'package:smart_catering_service/utils/extensions.dart';
import 'package:smart_catering_service/utils/my_safe_state.dart';
import 'package:smart_catering_service/utils/my_utils.dart';
import 'package:smart_catering_service/views/common/components/modal_progress_hud.dart';

import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_submit_button.dart';
import '../../profile/componants/profile_text_form_field.dart';

class AddEditAdminCateringScreen extends StatefulWidget {
  static const String routeName = "/AddEditAdminCateringScreen";

  const AddEditAdminCateringScreen({super.key});

  @override
  State<AddEditAdminCateringScreen> createState() => _AddEditAdminCateringScreenState();
}

class _AddEditAdminCateringScreenState extends State<AddEditAdminCateringScreen> with MySafeState {
  bool isLoading = false;

  late AdminUserProvider adminUserProvider;
  late AdminUserController adminUserController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Uint8List? thumbnailImageBytes;
  String? thumbnailImageUrl;
  List<String> filesToDelete = [];

  List<CateringPhotoModel> photos = <CateringPhotoModel>[];
  List<CateringPackageModelTemp> packages = <CateringPackageModelTemp>[];

  late CateringModel cateringModel;

  void initializeFromModel({CateringModel? model}) {
    cateringModel = model ?? CateringModel();

    thumbnailImageUrl = "";
    thumbnailImageBytes = null;

    titleController.text = cateringModel.title;
    descriptionController.text = cateringModel.description;
    thumbnailImageUrl = cateringModel.thumbnailUrl;
    thumbnailImageBytes = null;

    photos.clear();
    photos.addAll(cateringModel.photos.map((e) => CateringPhotoModel(imageUrl: e)));

    packages.clear();
    packages.addAll(cateringModel.packages.map((e) => CateringPackageModelTemp(
          id: e.id,
          title: e.title,
          description: e.description,
          thumbnailUrl: e.thumbnailUrl,
          enabled: e.enabled,
          price: e.price,
        )));

    mySetState();
  }

  Future pickThumbnailImage() async {
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
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: themeData.colorScheme.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
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

        thumbnailImageBytes = await newImage.readAsBytes();
        mySetState();
      }
    }
  }

  Future pickSliderImages() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      for (PlatformFile pFile in result.files) {
        if (pFile.path.checkEmpty) continue;

        CroppedFile? newImage = await ImageCropper().cropImage(
          compressFormat: ImageCompressFormat.png,
          sourcePath: pFile.path!,
          cropStyle: CropStyle.rectangle,
          aspectRatioPresets: [
            CropAspectRatioPreset.ratio16x9,
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: themeData.colorScheme.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.ratio16x9,
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

          Uint8List bytes = await newImage.readAsBytes();
          photos.add(CateringPhotoModel(imageBytes: bytes));
        }
      }
      mySetState();
    }
  }

  Future<String> uploadThumbnailImage({required String cateringId, required Uint8List image}) async {
    String downloadUrl = "";

    if (cateringId.isEmpty) {
      cateringId = "catering";
    }

    // String fileName = file.path.substring(file.path.lastIndexOf("/") + 1);
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
    Reference reference = FirebaseStorage.instance.ref().child("catering").child(cateringId).child("thumbnail").child(fileName);
    UploadTask uploadTask = reference.putData(image);

    TaskSnapshot snapshot = await uploadTask.then((snapshot) => snapshot);
    if (snapshot.state == TaskState.success) {
      downloadUrl = await snapshot.ref.getDownloadURL();

      /*final String downloadUrl = "https://storage.googleapis.com/${Firebase.app().options.storageBucket}/profile/$tempUserId/$bussinessId/$fileName";
          downloadUrls.add(downloadUrl);*/

      MyPrint.printOnConsole('$fileName Upload success');
    } else {
      MyPrint.printOnConsole('Error from image repo uploading $fileName: ${snapshot.toString()}');
      //throw ('This file is not an image');
    }

    return downloadUrl;
  }

  Future<List<CateringPackageModel>> uploadPackages({required String cateringId, required List<CateringPackageModelTemp> packages}) async {
    List<CateringPackageModel> newPackages = [];

    if (cateringId.isEmpty) {
      cateringId = "catering";
    }

    for (CateringPackageModelTemp model in packages) {
      String thumbnailImageUrl = model.thumbnailUrl;
      if(model.thumbnailBytes != null) {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
        Reference reference = FirebaseStorage.instance.ref().child("catering").child(cateringId).child("packages").child(fileName);
        UploadTask uploadTask = reference.putData(model.thumbnailBytes!);

        TaskSnapshot snapshot = await uploadTask.then((snapshot) => snapshot);
        if (snapshot.state == TaskState.success) {
          thumbnailImageUrl = await snapshot.ref.getDownloadURL();
        }
      }

      if(model.id.isEmpty) {
        model.id = MyUtils.getNewId(isFromUUuid: false);
      }

      CateringPackageModel newModel = CateringPackageModel(
        id: model.id,
        title: model.title,
        description: model.description,
        enabled: model.enabled,
        price: model.price,
        thumbnailUrl: thumbnailImageUrl,
      );

      newPackages.add(newModel);
    }

    return newPackages;
  }

  Future<List<String>> uploadPhotos({required String cateringId, required List<CateringPhotoModel> photos}) async {
    List<String> newPhotos = [];

    if (cateringId.isEmpty) {
      cateringId = "catering";
    }

    for (CateringPhotoModel model in photos) {
      String thumbnailImageUrl = model.imageUrl;
      if(model.imageBytes != null) {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
        Reference reference = FirebaseStorage.instance.ref().child("catering").child(cateringId).child("photos").child(fileName);
        UploadTask uploadTask = reference.putData(model.imageBytes!);

        TaskSnapshot snapshot = await uploadTask.then((snapshot) => snapshot);
        if (snapshot.state == TaskState.success) {
          thumbnailImageUrl = await snapshot.ref.getDownloadURL();
        }
      }

      newPhotos.add(thumbnailImageUrl);
    }

    return newPhotos;
  }

  Future<void> editDetails() async {
    isLoading = true;
    mySetState();

    String cateringId = cateringModel.id;
    if(cateringId.isEmpty) {
      cateringId = context.read<AuthenticationProvider>().userId.get();
    }

    String finalThumbnailUrl;
    if (thumbnailImageUrl.checkNotEmpty) {
      finalThumbnailUrl = thumbnailImageUrl!;
    } else {
      if (thumbnailImageBytes != null) {
        finalThumbnailUrl = await uploadThumbnailImage(cateringId: cateringId, image: thumbnailImageBytes!);
      } else {
        finalThumbnailUrl = "";
      }
    }

    List<CateringPackageModel> finalPackages = await uploadPackages(cateringId: cateringId, packages: packages);
    List<String> finalPhotos = await uploadPhotos(cateringId: cateringId, photos: photos);

    CateringModel newCateringModel = CateringModel(
      id: cateringModel.id,
      title: titleController.text,
      description: descriptionController.text,
      enabled: cateringModel.enabled,
      thumbnailUrl: finalThumbnailUrl,
      packages: finalPackages,
      photos: finalPhotos,
      createdTime: cateringModel.createdTime,
      updatedTime: cateringModel.updatedTime,
    );

    bool isUpdated = await adminUserController.updateCateringModel(cateringId: cateringId, cateringModel: newCateringModel);

    isLoading = false;
    mySetState();

    if(isUpdated) {
      if(context.checkMounted() && context.mounted) Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    AuthenticationProvider authenticationProvider = context.read<AuthenticationProvider>();
    adminUserProvider = context.read<AdminUserProvider>();
    adminUserController = AdminUserController(authenticationProvider: authenticationProvider, adminUserProvider: adminUserProvider);

    initializeFromModel(model: context.read<AdminUserProvider>().cateringModel.get());
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Catering Details",
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  getThumbnailImageWidget(),
                  const SizedBox(height: 10),
                  getTitleTextField(),
                  const SizedBox(height: 10),
                  getDescriptionTextField(),
                  const SizedBox(height: 10),
                  getEnabledSwitch(),
                  const SizedBox(height: 10),
                  getPhotosListviewWidget(),
                  const SizedBox(height: 10),
                  getPackagesListviewWidget(),
                  const SizedBox(height: 10),
                  getSubmitButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getThumbnailImageWidget() {
    Widget? imageWidget;
    Widget? imageActionWidget;

    if (thumbnailImageBytes != null) {
      imageWidget = Image.memory(
        thumbnailImageBytes!,
        height: 105,
        width: 105,
      );
      imageActionWidget = InkWell(
        onTap: () {
          thumbnailImageBytes = null;
          mySetState();
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Icon(Icons.close, color: themeData.primaryColor, size: 14),
        ),
      );
    } else if (thumbnailImageUrl.checkNotEmpty) {
      imageWidget = CommonCachedNetworkImage(
        borderRadius: 10,
        imageUrl: thumbnailImageUrl!,
        height: 105,
        width: 105,
      );
      imageActionWidget = InkWell(
        onTap: () {
          filesToDelete.add(thumbnailImageUrl!);
          thumbnailImageUrl = null;
          mySetState();
        },
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey, width: 1),
          ),
          child: Icon(Icons.close, color: themeData.primaryColor, size: 14),
        ),
      );
    } else {
      imageWidget = InkWell(
        onTap: () {
          pickThumbnailImage();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
          ),
          child: const Icon(Icons.add),
        ),
      );
    }

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 10, right: 10),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imageWidget,
            ),
          ),
        ),
        if (imageActionWidget != null)
          Positioned(
            top: 0,
            right: 0,
            child: imageActionWidget,
          ),
      ],
    );
  }

  Widget getTitleTextField() {
    return MyCommonTextField(
      controller: titleController,
      hintText: 'Enter Title',
      prefix: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Icon(
          Icons.title,
          color: themeData.primaryColor,
          size: 21,
        ),
      ),
      validator: (String? val) {
        if (val.checkEmpty) {
          return "Title cannot be empty";
        } else {
          return null;
        }
      },
    );
  }

  Widget getDescriptionTextField() {
    return MyCommonTextField(
      controller: descriptionController,
      hintText: 'Enter Description',
      minLines: 5,
      maxLines: 10,
      prefix: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Icon(
          Icons.description,
          color: themeData.primaryColor,
          size: 21,
        ),
      ),
      validator: (String? val) {
        if (val.checkEmpty) {
          return "Description cannot be empty";
        } else {
          return null;
        }
      },
    );
  }

  Widget getEnabledSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: SwitchListTile(
            value: cateringModel.enabled,
            onChanged: (bool value) {
              cateringModel.enabled = value;
              mySetState();
            },
            title: const Text("Enabled"),
          ),
        ),
      ],
    );
  }

  Widget getPhotosListviewWidget() {
    int listViewLength = 1 + photos.length;
    MyPrint.printOnConsole("Photos listViewLength:$listViewLength");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Photos",
          style: themeData.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: listViewLength,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return InkWell(
                  onTap: () {
                    pickSliderImages();
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add),
                  ),
                );
              }

              index--;

              CateringPhotoModel photoModel = photos[index];

              Widget imageWidget;
              if (photoModel.imageBytes != null) {
                imageWidget = Image.memory(photoModel.imageBytes!);
              } else if (photoModel.imageUrl.isNotEmpty) {
                imageWidget = CommonCachedNetworkImage(imageUrl: photoModel.imageUrl);
              } else {
                imageWidget = const Center(child: Text("Invalid Image"));
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5, right: 5),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: imageWidget,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          photos.remove(photoModel);
                          mySetState();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: Icon(Icons.close, color: themeData.primaryColor, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget getPackagesListviewWidget() {
    int listViewLength = packages.length;
    MyPrint.printOnConsole("Packages listViewLength:$listViewLength");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Packages",
              style: themeData.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            IconButton(
              onPressed: () async {
                dynamic value = await NavigationController.navigateToAddEditAdminCateringPackageScreen(
                  navigationOperationParameters: NavigationOperationParameters(
                    context: context,
                    navigationType: NavigationType.pushNamed,
                  ),
                  arguments: const AddEditAdminCateringPackageScreenNavigationArguments(cateringPackageModelTemp: null),
                );
                MyPrint.printOnConsole("value:$value");
                MyPrint.printOnConsole("value type:${value.runtimeType}");

                if(value is CateringPackageModelTemp) {
                  packages.add(value);
                  mySetState();
                }
              },
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: listViewLength,
          itemBuilder: (BuildContext context, int index) {
            CateringPackageModelTemp modelTemp = packages[index];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: getPackageCard(modelTemp: modelTemp),
            );
          },
        ),
      ],
    );
  }

  Widget getPackageCard({required CateringPackageModelTemp modelTemp}) {
    Widget imageWidget;
    if (modelTemp.thumbnailBytes != null) {
      imageWidget = Image.memory(modelTemp.thumbnailBytes!);
    } else if (modelTemp.thumbnailUrl.isNotEmpty) {
      imageWidget = CommonCachedNetworkImage(imageUrl: modelTemp.thumbnailUrl);
    } else {
      imageWidget = const Center(child: Text("Invalid Image"));
    }

    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          border: Border.all(color: themeData.primaryColor),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            imageWidget,
            const SizedBox(height: 10),
            Text(modelTemp.title),
            Text(modelTemp.description),
            Text("Price: ${modelTemp.price}"),
            SwitchListTile(
              value: modelTemp.enabled,
              onChanged: (bool value) {
                modelTemp.enabled = value;
                mySetState();
              },
              title: const Text("Enabled"),
            ),
            Row(
              children: [
                CommonSubmitButton(
                  onTap: () async {
                    dynamic value = await NavigationController.navigateToAddEditAdminCateringPackageScreen(
                      navigationOperationParameters: NavigationOperationParameters(
                        context: context,
                        navigationType: NavigationType.pushNamed,
                      ),
                      arguments: AddEditAdminCateringPackageScreenNavigationArguments(cateringPackageModelTemp: modelTemp),
                    );
                    MyPrint.printOnConsole("value:$value");
                    MyPrint.printOnConsole("value type:${value.runtimeType}");

                    if(value is CateringPackageModelTemp) {
                      modelTemp.id = value.id;
                      modelTemp.title = value.title;
                      modelTemp.description = value.description;
                      modelTemp.thumbnailUrl = value.thumbnailUrl;
                      modelTemp.thumbnailBytes = value.thumbnailBytes;
                      modelTemp.price = value.price;
                      modelTemp.enabled = value.enabled;
                      mySetState();
                    }
                  },
                  text: "Edit",
                  verticalPadding: 10,
                  horizontalPadding: 20,
                  fontSize: 15,
                ),
                CommonSubmitButton(
                  onTap: () async {
                    packages.remove(modelTemp);
                    mySetState();
                  },
                  text: "Delete",
                  verticalPadding: 10,
                  horizontalPadding: 20,
                  fontSize: 15,
                  backgroundColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getSubmitButton() {
    return CommonSubmitButton(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());

        bool isFormValid = _formKey.currentState?.validate() ?? false;
        bool isThumbnailValid = thumbnailImageBytes != null || thumbnailImageUrl.checkNotEmpty;
        bool isPackagesValid = packages.isNotEmpty;
        bool isPhotosValid = photos.isNotEmpty;

        if (isFormValid && isThumbnailValid && isPackagesValid && isPhotosValid) {
          //MyPrint.printOnConsole("Valid");
          editDetails();
        }
        else if(!isFormValid) {

        }
        else if(!isThumbnailValid) {
          MyToast.showError(context: context, msg: "Thumbnail must be selected");
        }
        else if(!isPackagesValid) {
          MyToast.showError(context: context, msg: "Packages must not be empty");
        }
        else if(!isPhotosValid) {
          MyToast.showError(context: context, msg: "Photos must not be empty");
        }
        else {
          //MyPrint.printOnConsole("Not Valid");
        }
      },
      text: "Submit",
      verticalPadding: 10,
      horizontalPadding: 20,
      fontSize: 15,
    );
  }
}

class CateringPhotoModel {
  String imageUrl;
  Uint8List? imageBytes;

  CateringPhotoModel({
    this.imageUrl = "",
    this.imageBytes,
  });
}

class CateringPackageModelTemp {
  String id = "";
  String title = "";
  String description = "";
  String thumbnailUrl = "";
  Uint8List? thumbnailBytes;
  bool enabled = false;
  double price = 0;

  CateringPackageModelTemp({
    this.id = "",
    this.title = "",
    this.description = "",
    this.thumbnailUrl = "",
    this.thumbnailBytes,
    this.enabled = false,
    this.price = 0,
  });
}
