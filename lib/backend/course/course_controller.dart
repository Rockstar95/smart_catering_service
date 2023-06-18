import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_catering_service/backend/authentication/authentication_provider.dart';
import 'package:smart_catering_service/backend/common/firestore_controller.dart';
import 'package:smart_catering_service/backend/navigation/navigation_controller.dart';
import 'package:smart_catering_service/models/course/data_model/course_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import 'course_provider.dart';
import 'course_repository.dart';

class CourseController {
  late CourseRepository _courseRepository;
  late CourseProvider _courseProvider;

  CourseController({
    required CourseProvider? provider,
    CourseRepository? repository,
  }) {
    _courseRepository = repository ?? CourseRepository();
    _courseProvider = provider ?? CourseProvider();
  }

  CourseRepository get courseRepository => _courseRepository;
  CourseProvider get courseProvider => _courseProvider;

  Future<List<CourseModel>> getCoursesPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getCoursesPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    CourseProvider provider = courseProvider;

    if(!isRefresh && isFromCache && provider.coursesLength > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.courses.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreCourses.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastCourseDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isCoursesFirstTimeLoading.set(value: true, isNotify: false);
      provider.isCoursesLoading.set(value: false, isNotify: false);
      provider.courses.setList(list: <CourseModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreCourses.get()) {
        MyPrint.printOnConsole('No More Courses', tag: tag);
        return provider.courses.getList(isNewInstance: true);
      }
      if (provider.isCoursesLoading.get()) return provider.courses.getList(isNewInstance: true);

      provider.isCoursesLoading.set(value: true, isNotify: isNotify);

      Query<Map<String, dynamic>> query = FirebaseNodes.coursesCollectionReference
          .limit(AppConstants.coursesDocumentLimitForPagination)
          .orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastCourseDocument.get();
      if(snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      }
      else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Courses:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.coursesDocumentLimitForPagination) provider.hasMoreCourses.set(value: false, isNotify: false);

      if(querySnapshot.docs.isNotEmpty) provider.lastCourseDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<CourseModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          CourseModel productModel = CourseModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      provider.courses.setList(list: list, isClear: false, isNotify: false);
      provider.isCoursesFirstTimeLoading.set(value: false, isNotify: true);
      provider.isCoursesLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Courses Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Courses Length in Provider:${provider.coursesLength}", tag: tag);
      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in CourseController().getCoursesPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.courses.setList(list: [], isClear: true, isNotify: false);
      provider.hasMoreCourses.set(value: true, isNotify: false);
      provider.lastCourseDocument.set(value: null, isNotify: false);
      provider.isCoursesFirstTimeLoading.set(value: false, isNotify: false);
      provider.isCoursesLoading.set(value: false, isNotify: true);
      return [];
    }
  }

  Future<List<CourseModel>> getMyCoursesList({bool isRefresh = true, required List<String> myCourseIds, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getMyCoursesList called with isRefresh:$isRefresh, myCourseIds:$myCourseIds, isNotify:$isNotify", tag: tag);

    CourseProvider provider = courseProvider;

    if(!isRefresh) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.myCourses.getList(isNewInstance: true);
    }

    if(provider.isMyCoursesFirstTimeLoading.get()) {
      MyPrint.printOnConsole("Returning from CourseController().getMyCoursesList() because myCourses already fetching", tag: tag);
      return provider.myCourses.getList(isNewInstance: true);
    }

    MyPrint.printOnConsole("Refresh", tag: tag);
    provider.isMyCoursesFirstTimeLoading.set(value: true, isNotify: false);
    provider.myCourses.setList(list: <CourseModel>[], isNotify: isNotify);

    try {
      List<MyFirestoreQueryDocumentSnapshot> docs = await FirestoreController.getDocsFromCollection(
        collectionReference: FirebaseNodes.coursesCollectionReference,
        docIds: myCourseIds,
      );
      MyPrint.printOnConsole("Documents Length in Firestore for My Courses:${docs.length}", tag: tag);

      List<CourseModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot in docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          CourseModel productModel = CourseModel.fromMap(documentSnapshot.data()!);
          list.add(productModel);
        }
      }
      provider.myCourses.setList(list: list, isClear: true, isNotify: false);
      provider.isMyCoursesFirstTimeLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Courses Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Courses Length in Provider:${provider.myCoursesLength}", tag: tag);
      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in CourseController().getMyCoursesList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.myCourses.setList(list: [], isClear: true, isNotify: false);
      provider.isMyCoursesFirstTimeLoading.set(value: false, isNotify: false);
      return [];
    }
  }

  static Future<void> launchGoogleFormInCourse({required String formUrl}) async {
    if(formUrl.isEmpty) {
      return;
    }

    BuildContext? context = NavigationController.mainScreenNavigator.currentContext;

    String userName = "";

    if(context != null) {
      AuthenticationProvider authenticationProvider = context.read<AuthenticationProvider>();
      userName = authenticationProvider.userModel.get()?.name ?? "";
    }

    formUrl = formUrl.replaceAll("{{name}}", userName);
    MyPrint.printOnConsole("Final googleFormUrl:$formUrl");

    MyUtils.launchUrl(url: formUrl);
  }
}
