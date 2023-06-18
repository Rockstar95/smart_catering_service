import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_catering_service/backend/admin/admin_provider.dart';
import 'package:smart_catering_service/backend/admin/admin_repository.dart';
import 'package:smart_catering_service/configs/constants.dart';
import 'package:smart_catering_service/configs/typedefs.dart';
import 'package:smart_catering_service/models/common/data_model/new_document_data_model.dart';
import 'package:smart_catering_service/models/other/data_model/feedback_model.dart';
import 'package:smart_catering_service/utils/parsing_helper.dart';

import '../../models/common/data_model/property_model.dart';
import '../../models/other/data_model/about_model.dart';
import '../../models/other/data_model/faq_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class AdminController {
  late AdminProvider _adminProvider;
  late AdminRepository _adminRepository;

  AdminController({required AdminProvider? adminProvider, AdminRepository? repository}) {
    _adminProvider = adminProvider ?? AdminProvider();
    _adminRepository = repository ?? AdminRepository();
  }

  AdminProvider get adminProvider => _adminProvider;

  AdminRepository get adminRepository => _adminRepository;

  Future<void> getPropertyModelAndSaveInProvider() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminController().getPropertyModelAndSaveInProvider() called", tag: tag);

    try {
      PropertyModel? propertyModel = await adminRepository.getPropertyModel();
      adminProvider.propertyModel.set(value: propertyModel);

      MyPrint.printOnConsole("propertyModel:$propertyModel", tag: tag);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminController().getPropertyModelAndSaveInProvider():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<void> getNewTimestampAndSaveInProvider() async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminController().getNewTimestampAndSaveInProvider() called", tag: tag);

    try {
      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      adminProvider.timeStamp.set(value: newDocumentDataModel.timestamp);

      MyPrint.printOnConsole("new timeStamp:${newDocumentDataModel.timestamp.toDate()}", tag: tag);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminController().getNewTimestampAndSaveInProvider():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<void> sendEnrollmentRequestInWhatsapp({required String userName, required String userMobile, required String courseName}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminController().sendEnrollmentRequestInWhatsapp() called", tag: tag);

    try {
      String text = "Hello, I'm $userName and this is my Mobile Number $userMobile, I want to Enroll in the Course '$courseName'";

      await sendInWhatsapp(text: text);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminController().sendEnrollmentRequestInWhatsapp():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<void> sendRenewalRequestInWhatsapp({required String userName, required String userMobile, required String courseName}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminController().sendRenewalRequestInWhatsapp() called", tag: tag);

    try {
      String text = "Hello, I'm $userName and this is my Mobile Number $userMobile, I want to Renew the Course '$courseName'";

      await sendInWhatsapp(text: text);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminController().sendRenewalRequestInWhatsapp():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<void> sendInWhatsapp({required String text}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminController().sendInWhatsapp() called with text:'$text'", tag: tag);

    if (text.isEmpty) {
      MyPrint.printOnConsole("Returning From AdminController().sendInWhatsapp() because text is empty");
      return;
    }

    String mobileNumber = adminProvider.propertyModel.get()?.enrollCourseContactNumber ?? "";
    MyPrint.printOnConsole("MobileNumber:'$mobileNumber'", tag: tag);

    if (mobileNumber.isEmpty) {
      MyPrint.printOnConsole("Returning From AdminController().sendInWhatsapp() because mobileNumber is empty");
      return;
    }

    try {
      await MyUtils.launchWhatsAppChat(mobileNumber: mobileNumber, message: text);
      // await Share.share(text);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminController().sendInWhatsapp():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<AboutModel> getAboutData() async {
    AdminProvider provider = adminProvider;

    // if (dataProvider.aboutModel != null) return dataProvider.aboutModel!;

    MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.adminAboutDocumentReference.get();
    MyPrint.printOnConsole("About Snapshot Data:${snapshot.data()}");

    if (snapshot.exists && (snapshot.data() ?? {}).isNotEmpty) {
      provider.aboutModel.set(value: AboutModel.fromMap(snapshot.data()!), isNotify: false);
    }

    AboutModel aboutModel = provider.aboutModel.get();

    MyPrint.printOnConsole("About Model:$aboutModel");

    return aboutModel;
  }

  Future<List<FAQModel>> getFaq({bool isRefresh = true}) async {
    AdminProvider provider = adminProvider;

    if (!isRefresh && provider.faqList.getList(isNewInstance: false).isNotEmpty) return provider.faqList.getList();

    List<FAQModel> faqs = <FAQModel>[];

    MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.adminFaqDocumentReference.get();
    if (snapshot.exists && (snapshot.data() ?? {}).isNotEmpty) {
      snapshot.data()!.forEach((String key, dynamic value) {
        Map<String, dynamic> map = ParsingHelper.parseMapMethod<dynamic, dynamic, String, dynamic>(value);

        if (map.isNotEmpty) {
          FAQModel faqModel = FAQModel.fromMap(map);
          if (faqModel.enabled) {
            faqs.add(faqModel);
          }
        }
      });
    }

    provider.faqList.setList(list: faqs, isClear: true, isNotify: false);

    return provider.faqList.getList();
  }

  Future<bool> sendFeedback({
    required FeedbackModel feedbackModel,
  }) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminController().sendFeedback() called", tag: tag);

    if(feedbackModel.id.isEmpty) feedbackModel.id = MyUtils.getNewId(isFromUUuid: false);
    Map<String, dynamic> data = feedbackModel.toMap();

    data["createdTime"] = FieldValue.serverTimestamp();

    bool success = await FirebaseNodes.adminFeedbackDocumentReference.update({feedbackModel.id: data}).then((value) {
      MyPrint.printOnConsole("Feedback Sent Successfully", tag: tag);

      return true;
    }).catchError((e, s) {
      MyPrint.printOnConsole("Error in Sending Feedback:$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);

      return false;
    });

    return success;
  }
}
