import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:uuid/uuid.dart';

import '../backend/common/firestore_controller.dart';
import '../configs/constants.dart';
import '../models/common/data_model/new_document_data_model.dart';
import 'my_print.dart';
import 'my_toast.dart';

class MyUtils {
  static Future<void> copyToClipboard(BuildContext? context, String string) async {
    if (string.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: string));
      if (context != null) {
        MyToast.showSuccess(context: context, msg: "Copied");
      }
    }
  }

  static String getNewId({bool isFromUUuid = true}) {
    if (isFromUUuid) {
      return const Uuid().v1().replaceAll("-", "");
    } else {
      return FirebaseFirestore.instance.collection("sdf").doc().id;
    }
  }

  static String encodeJson(Object? object) {
    try {
      return jsonEncode(object);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in MyUtils.encodeJson():$e");
      MyPrint.printOnConsole(s);
      return "";
    }
  }

  static dynamic decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in MyUtils.decodeJson():$e");
      MyPrint.printOnConsole(s);
      return null;
    }
  }

  static Future<NewDocumentDataModel> getNewDocIdAndTimeStamp({bool isGetTimeStamp = true}) async {
    String docId = FirestoreController.documentReference(
      collectionName: "collectionName",
    ).id;
    Timestamp timestamp = Timestamp.now();

    if (isGetTimeStamp) {
      await FirebaseNodes.timestampCollectionReference.add({"temp_timestamp": FieldValue.serverTimestamp()}).then((DocumentReference<Map<String, dynamic>> reference) async {
        docId = reference.id;

        if (isGetTimeStamp) {
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await reference.get();
          timestamp = documentSnapshot.data()?['temp_timestamp'];
        }

        reference.delete();
      }).catchError((e, s) {
        // reportErrorToCrashlytics(e, s, reason: "Error in DataController.getNewDocId()");
      });

      if (docId.isEmpty) {
        docId = FirestoreController.documentReference(
          collectionName: "collectionName",
        ).id;
      }
    }

    return NewDocumentDataModel(docId: docId, timestamp: timestamp);
  }

  static void hideShowKeyboard({bool isHide = true}) {
    SystemChannels.textInput.invokeMethod(isHide ? 'TextInput.hide' : 'TextInput.show');
  }

  static Future<bool> launchUrl({required String url, LaunchMode launchMode = LaunchMode.externalApplication}) async {
    String tag = getNewId();
    MyPrint.printOnConsole("MyUtils.launchUrl() called", tag: tag);
    bool isCanLaunch = false, isLaunched = false;

    try {
      isCanLaunch = await canLaunchUrlString(url);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Checking canLaunchUrlString in MyUtils.launchUrl():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    if (isCanLaunch) {
      try {
        isLaunched = await launchUrlString(
          url,
          mode: launchMode,
        );
      } catch (e, s) {
        MyPrint.printOnConsole("Error in Checking canLaunchUrlString in MyUtils.launchUrl():$e", tag: tag);
        MyPrint.printOnConsole(s, tag: tag);
      }
    }

    return isLaunched;
  }

  static bool isValidMobileNumber(String mobileNumber) {
    RegExp exp = RegExp(r"^\s*(?:\+?(\d{1,3}))?([-. (]*(\d{3})[-. )]*)?((\d{3})[-. ]*(\d{2,4})(?:[-.x ]*(\d+))?)\s*$");

    return exp.hasMatch(mobileNumber);
  }

  static Future<void> launchWhatsAppChat({required String mobileNumber, String message = ""}) async {
    MyPrint.printOnConsole("launchWhatsAppChat called with mobileNumber:$mobileNumber");

    if(mobileNumber.isEmpty || !isValidMobileNumber(mobileNumber)) {
      MyPrint.printOnConsole("Mobile Number is Empty or Invalid");
      return;
    }

    String urlString = "https://wa.me/$mobileNumber?text=${Uri.encodeComponent(message)}";
    MyPrint.printOnConsole("urlString:$urlString");

    await launchUrlString(urlString, mode: LaunchMode.externalApplication);
  }
}
