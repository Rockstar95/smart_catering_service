import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:smart_catering_service/backend/navigation/navigation_arguments.dart';
import 'package:smart_catering_service/utils/extensions.dart';
import 'package:smart_catering_service/utils/my_safe_state.dart';
import 'package:smart_catering_service/utils/my_toast.dart';
import 'package:smart_catering_service/utils/parsing_helper.dart';

import '../../../utils/my_print.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_submit_button.dart';
import '../../profile/componants/profile_text_form_field.dart';
import 'add_edit_admin_catering_screen.dart';

class AddEditAdminCateringPackageScreen extends StatefulWidget {
  static const String routeName = "/AddEditAdminCateringPackageScreen";

  final AddEditAdminCateringPackageScreenNavigationArguments arguments;

  const AddEditAdminCateringPackageScreen({
    super.key,
    required this.arguments,
  });

  @override
  State<AddEditAdminCateringPackageScreen> createState() => _AddEditAdminCateringPackageScreenState();
}

class _AddEditAdminCateringPackageScreenState extends State<AddEditAdminCateringPackageScreen> with MySafeState {
  bool isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  Uint8List? thumbnailImageBytes;
  String? thumbnailImageUrl;
  List<String> filesToDelete = [];

  late CateringPackageModelTemp cateringPackageModelTemp;

  void initializeFromModel({CateringPackageModelTemp? model}) {
    cateringPackageModelTemp = model ?? CateringPackageModelTemp();

    thumbnailImageUrl = null;
    thumbnailImageBytes = null;

    titleController.text = cateringPackageModelTemp.title;
    descriptionController.text = cateringPackageModelTemp.description;
    priceController.text = cateringPackageModelTemp.price.toInt().toString();
    thumbnailImageUrl = cateringPackageModelTemp.thumbnailUrl;
    thumbnailImageBytes = cateringPackageModelTemp.thumbnailBytes;

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

  Future<void> submitDetails() async {
    cateringPackageModelTemp.title = titleController.text;
    cateringPackageModelTemp.description = descriptionController.text;
    cateringPackageModelTemp.thumbnailUrl = thumbnailImageUrl ?? "";
    cateringPackageModelTemp.thumbnailBytes = thumbnailImageBytes;
    cateringPackageModelTemp.price = ParsingHelper.parseDoubleMethod(priceController.text.trim());

    Navigator.pop(context, cateringPackageModelTemp);
  }

  @override
  void initState() {
    super.initState();

    initializeFromModel(model: widget.arguments.cateringPackageModelTemp);
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Package Details",
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
                getPriceTextField(),
                const SizedBox(height: 10),
                getEnabledSwitch(),
                const SizedBox(height: 10),
                getSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getThumbnailImageWidget() {
    Widget imageWidget;
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
        borderRadius: 100,
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

  Widget getPriceTextField() {
    return MyCommonTextField(
      controller: priceController,
      hintText: 'Enter Price',
      prefix: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Icon(
          Icons.price_change,
          color: themeData.primaryColor,
          size: 21,
        ),
      ),
      textInputType: const TextInputType.numberWithOptions(decimal: false, signed: false),
      textInputFormatter: [
        FilteringTextInputFormatter.deny("."),
        FilteringTextInputFormatter.deny(" "),
      ],
      validator: (String? val) {
        if (val.checkEmpty) {
          return "Price cannot be empty";
        }

        double? price = double.tryParse(val ?? "");
        if(price == null) {
          return "Invalid Price";
        }

        return null;
      },
    );
  }

  Widget getEnabledSwitch() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: SwitchListTile(
            value: cateringPackageModelTemp.enabled,
            onChanged: (bool value) {
              cateringPackageModelTemp.enabled = value;
              mySetState();
            },
            title: const Text("Enabled"),
          ),
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

        if (isFormValid && isThumbnailValid) {
          //MyPrint.printOnConsole("Valid");
          submitDetails();
        }
        else if(!isFormValid) {

        }
        else if(!isThumbnailValid) {
          MyToast.showError(context: context, msg: "Thumbnail must be selected");
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
