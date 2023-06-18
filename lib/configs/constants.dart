import '../backend/common/firestore_controller.dart';
import 'typedefs.dart';

class AppConstants {
  static const int coursesDocumentLimitForPagination = 10;
  static const int coursesRefreshLimitForPagination = 3;
}

class FirestoreExceptionCodes {
  static const String notFound = "not-found";
}

class FirebaseNodes {
  //region Admin
  static const String adminCollection = "admin";

  static MyFirestoreCollectionReference get adminCollectionReference => FirestoreController.collectionReference(
    collectionName: adminCollection,
  );

  static MyFirestoreDocumentReference adminDocumentReference({String? documentId}) => FirestoreController.documentReference(
    collectionName: adminCollection,
    documentId: documentId,
  );

  //region Property Document
  static const String propertyDocument = "property";

  static MyFirestoreDocumentReference get adminPropertyDocumentReference => adminDocumentReference(
    documentId: propertyDocument,
  );
  //endregion

  //region About Document
  static const String aboutDocument = "about";

  static MyFirestoreDocumentReference get adminAboutDocumentReference => adminDocumentReference(
    documentId: aboutDocument,
  );
  //endregion

  //region FAQ Document
  static const String faqDocument = "faq";

  static MyFirestoreDocumentReference get adminFaqDocumentReference => adminDocumentReference(
    documentId: faqDocument,
  );
  //endregion

  //region Feedback Document
  static const String feedbackDocument = "feedback";

  static MyFirestoreDocumentReference get adminFeedbackDocumentReference => adminDocumentReference(
    documentId: feedbackDocument,
  );
  //endregion
  //endregion

  //region Courses Collection
  static const String coursesCollection = 'courses';

  static MyFirestoreCollectionReference get coursesCollectionReference => FirestoreController.collectionReference(
    collectionName: FirebaseNodes.coursesCollection,
  );

  static MyFirestoreDocumentReference coursesDocumentReference({String? courseId}) => FirestoreController.documentReference(
    collectionName: FirebaseNodes.coursesCollection,
    documentId: courseId,
  );
  //endregion

  //region User
  static const String usersCollection = "users";

  static MyFirestoreCollectionReference get usersCollectionReference => FirestoreController.collectionReference(
    collectionName: usersCollection,
  );

  static MyFirestoreDocumentReference userDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: usersCollection,
    documentId: userId,
  );
  //endregion

  //region Timestamp Collection
  static const String timestampCollection = "timestamp_collection";

  static MyFirestoreCollectionReference get timestampCollectionReference => FirestoreController.collectionReference(
    collectionName: timestampCollection,
  );
  //endregion
}

//Shared Preference Keys
class SharePreferenceKeys {
  static const String appThemeMode = "themeMode";
}

class NotificationTypes {
  static const String editCourse = "editCourse";
  static const String courseValidityExtended = "courseValidityExtended";
  static const String courseAssigned = "courseAssigned";
  static const String courseExpired = "courseExpired";
}

class UIConstants {
  static const String noUserImageUrl = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
}

class AppAssets {
  static const String logo = 'assets/images/logo.png';
}

String ISFIRST = "isfirst";
String LAST_OPENED_TIME = "last_opened_time";
