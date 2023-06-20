import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/admin_user/admin_user_controller.dart';
import 'package:smart_catering_service/backend/admin_user/admin_user_provider.dart';
import 'package:smart_catering_service/backend/authentication/authentication_provider.dart';
import 'package:smart_catering_service/configs/constants.dart';
import 'package:smart_catering_service/models/party_plot/data_model/party_plot_model.dart';
import 'package:smart_catering_service/utils/extensions.dart';
import 'package:smart_catering_service/utils/my_safe_state.dart';
import 'package:smart_catering_service/views/common/components/modal_progress_hud.dart';

import '../../../utils/my_print.dart';
import '../../../utils/my_toast.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_submit_button.dart';
import '../../profile/componants/profile_text_form_field.dart';

class AddEditAdminPartyPlotScreen extends StatefulWidget {
  static const String routeName = "/AddEditAdminPartyPlotScreen";

  const AddEditAdminPartyPlotScreen({super.key});

  @override
  State<AddEditAdminPartyPlotScreen> createState() => _AddEditAdminPartyPlotScreenState();
}

class _AddEditAdminPartyPlotScreenState extends State<AddEditAdminPartyPlotScreen> with MySafeState {
  bool isLoading = false;

  late AdminUserProvider adminUserProvider;
  late AdminUserController adminUserController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Uint8List? thumbnailImageBytes;
  String? thumbnailImageUrl;
  List<String> filesToDelete = [];

  List<PartyPlotPhotoModel> photos = <PartyPlotPhotoModel>[];

  String? locationArea;
  String? locationCity;

  late PartyPlotModel partyPlotModel;

  void initializeFromModel({PartyPlotModel? model}) {
    partyPlotModel = model ?? PartyPlotModel();

    thumbnailImageUrl = "";
    thumbnailImageBytes = null;

    titleController.text = partyPlotModel.title;
    descriptionController.text = partyPlotModel.description;
    thumbnailImageUrl = partyPlotModel.thumbnailUrl;
    thumbnailImageBytes = null;

    photos.clear();
    photos.addAll(partyPlotModel.photos.map((e) => PartyPlotPhotoModel(imageUrl: e)));

    locationArea = partyPlotModel.locationArea;
    if (locationArea!.isEmpty) locationArea = null;

    locationCity = partyPlotModel.locationCity;
    if (locationCity!.isEmpty) locationCity = null;

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
          photos.add(PartyPlotPhotoModel(imageBytes: bytes));
        }
      }
      mySetState();
    }
  }

  Future<String> uploadThumbnailImage({required String partyPlotId, required Uint8List image}) async {
    String downloadUrl = "";

    if (partyPlotId.isEmpty) {
      partyPlotId = "catering";
    }

    // String fileName = file.path.substring(file.path.lastIndexOf("/") + 1);
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
    Reference reference = FirebaseStorage.instance.ref().child("partyPlot").child(partyPlotId).child("thumbnail").child(fileName);
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

  Future<List<String>> uploadPhotos({required String partyPlotId, required List<PartyPlotPhotoModel> photos}) async {
    List<String> newPhotos = [];

    if (partyPlotId.isEmpty) {
      partyPlotId = "catering";
    }

    for (PartyPlotPhotoModel model in photos) {
      String thumbnailImageUrl = model.imageUrl;
      if (model.imageBytes != null) {
        String fileName = "${DateTime.now().millisecondsSinceEpoch}.png";
        Reference reference = FirebaseStorage.instance.ref().child("partyPlot").child(partyPlotId).child("photos").child(fileName);
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

    String cateringId = partyPlotModel.id;
    if (cateringId.isEmpty) {
      cateringId = context.read<AuthenticationProvider>().userId.get();
    }

    String finalThumbnailUrl;
    if (thumbnailImageUrl.checkNotEmpty) {
      finalThumbnailUrl = thumbnailImageUrl!;
    } else {
      if (thumbnailImageBytes != null) {
        finalThumbnailUrl = await uploadThumbnailImage(partyPlotId: cateringId, image: thumbnailImageBytes!);
      } else {
        finalThumbnailUrl = "";
      }
    }

    List<String> finalPhotos = await uploadPhotos(partyPlotId: cateringId, photos: photos);

    PartyPlotModel newPartyPlotModel = PartyPlotModel(
      id: partyPlotModel.id,
      title: titleController.text,
      description: descriptionController.text,
      enabled: partyPlotModel.enabled,
      thumbnailUrl: finalThumbnailUrl,
      photos: finalPhotos,
      minPeople: partyPlotModel.minPeople,
      maxPeople: partyPlotModel.maxPeople,
      locationCity: locationCity ?? "",
      locationArea: locationArea ?? "",
      createdTime: partyPlotModel.createdTime,
      updatedTime: partyPlotModel.updatedTime,
    );

    bool isUpdated = await adminUserController.updatePartyPlotModel(partyPlotId: cateringId, partyPlotModel: newPartyPlotModel);

    isLoading = false;
    mySetState();

    if (isUpdated) {
      if (context.checkMounted() && context.mounted) Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();

    AuthenticationProvider authenticationProvider = context.read<AuthenticationProvider>();
    adminUserProvider = context.read<AdminUserProvider>();
    adminUserController = AdminUserController(authenticationProvider: authenticationProvider, adminUserProvider: adminUserProvider);

    initializeFromModel(model: context.read<AdminUserProvider>().partyPlotModel.get());
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return ModalProgressHUD(
      inAsyncCall: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Party Plot Details",
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
                  getPeopleSizeRangeSlider(),
                  const SizedBox(height: 10),
                  getLocationWidget(),
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
            value: partyPlotModel.enabled,
            onChanged: (bool value) {
              partyPlotModel.enabled = value;
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

              PartyPlotPhotoModel photoModel = photos[index];

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

  Widget getPeopleSizeRangeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "People Size",
          style: themeData.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        RangeSlider(
          onChanged: (RangeValues values) {
            partyPlotModel.minPeople = values.start;
            partyPlotModel.maxPeople = values.end;
            mySetState();
          },
          values: RangeValues(partyPlotModel.minPeople, partyPlotModel.maxPeople),
          min: 0,
          max: 5000,
          divisions: 50,
          labels: RangeLabels(partyPlotModel.minPeople.round().toString(), partyPlotModel.maxPeople.round().toString()),
        ),
      ],
    );
  }

  Widget getLocationWidget() {
    List<String> cityList = AppConstants.cityAreaMap.keys.toList();
    if ((cityList.isEmpty && locationCity.checkNotEmpty) || (locationCity != null && !cityList.contains(locationCity))) {
      locationCity = null;
    }

    List<String> areaList = [];
    if (locationCity != null) {
      areaList.addAll(AppConstants.cityAreaMap[locationCity] ?? <String>[]);
      if ((areaList.isEmpty && locationArea.checkNotEmpty) || (locationArea != null && !areaList.contains(locationArea))) {
        locationArea = null;
      }
    } else {
      if (locationArea != null) locationArea = null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Location",
          style: themeData.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: locationCity,
          onChanged: (String? value) {
            locationCity = value;
            if (value == null) {
              locationArea = null;
            }
            mySetState();
          },
          hint: Text(
            "Select City",
            style: themeData.textTheme.labelMedium,
          ),
          dropdownColor: Colors.white,
          isDense: false,
          underline: const SizedBox(),
          items: cityList.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: themeData.textTheme.labelMedium?.copyWith(
                  // color: Colors.black,
                  fontWeight: FontWeight.w600,
                  // fontSize: 20,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        DropdownButton<String>(
          value: locationArea,
          onChanged: (String? value) {
            locationArea = value;
            mySetState();
          },
          hint: Text(
            "Select Area",
            style: themeData.textTheme.labelMedium,
          ),
          dropdownColor: Colors.white,
          isDense: false,
          underline: const SizedBox(),
          items: areaList.map((e) {
            return DropdownMenuItem<String>(
              value: e,
              child: Text(
                e,
                style: themeData.textTheme.labelMedium?.copyWith(
                  // color: Colors.black,
                  fontWeight: FontWeight.w600,
                  // fontSize: 20,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget getSubmitButton() {
    return CommonSubmitButton(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());

        bool isFormValid = _formKey.currentState?.validate() ?? false;
        bool isThumbnailValid = thumbnailImageBytes != null || thumbnailImageUrl.checkNotEmpty;
        bool isPhotosValid = photos.isNotEmpty;
        bool isLocationValid = locationCity.checkNotEmpty && locationArea.checkNotEmpty;

        if (isFormValid && isThumbnailValid && isPhotosValid && isLocationValid) {
          //MyPrint.printOnConsole("Valid");
          editDetails();
        } else if (!isFormValid) {
        } else if (!isThumbnailValid) {
          MyToast.showError(context: context, msg: "Thumbnail must be selected");
        } else if (!isPhotosValid) {
          MyToast.showError(context: context, msg: "Photos must not be empty");
        } else if (!isLocationValid) {
          MyToast.showError(context: context, msg: "Location must be selected");
        } else {
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

class PartyPlotPhotoModel {
  String imageUrl;
  Uint8List? imageBytes;

  PartyPlotPhotoModel({
    this.imageUrl = "",
    this.imageBytes,
  });
}
