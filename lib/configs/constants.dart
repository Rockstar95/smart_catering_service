import '../backend/common/firestore_controller.dart';
import 'typedefs.dart';

class AppConstants {
  static const int cateringsDocumentLimitForPagination = 10;
  static const int cateringsRefreshLimitForPagination = 3;

  static const int partyPlotsDocumentLimitForPagination = 10;
  static const int partyPlotsRefreshLimitForPagination = 3;

  static const Map<String, List<String>> cityAreaMap = {
    "Vadodara" : [
      "Akota",
      "Manjalpur",
      "Vaghodia",
      "Sama",
      "Gotri",
    ],
    "Ahmedabad" : [
      "Naroda",
      "Narol",
      "Kalupur",
      "Sabarmati",
    ],
  };
}

class FirestoreExceptionCodes {
  static const String notFound = "not-found";
}

class FirebaseNodes {
  //region Admin User
  static const String adminUsersCollection = "adminUsers";

  static MyFirestoreCollectionReference get adminUsersCollectionReference => FirestoreController.collectionReference(
    collectionName: adminUsersCollection,
  );

  static MyFirestoreDocumentReference adminUserDocumentReference({String? userId}) => FirestoreController.documentReference(
    collectionName: adminUsersCollection,
    documentId: userId,
  );
  //endregion

  //region Catering Collection
  static const String cateringCollection = 'catering';

  static MyFirestoreCollectionReference get cateringCollectionReference => FirestoreController.collectionReference(
    collectionName: FirebaseNodes.cateringCollection,
  );

  static MyFirestoreDocumentReference cateringDocumentReference({String? cateringId}) => FirestoreController.documentReference(
    collectionName: FirebaseNodes.cateringCollection,
    documentId: cateringId,
  );
  //endregion

  //region PartyPlot Collection
  static const String partyPlotCollection = 'partyPlot';

  static MyFirestoreCollectionReference get partyPlotCollectionReference => FirestoreController.collectionReference(
    collectionName: FirebaseNodes.partyPlotCollection,
  );

  static MyFirestoreDocumentReference partyPlotDocumentReference({String? partyPlotId}) => FirestoreController.documentReference(
    collectionName: FirebaseNodes.partyPlotCollection,
    documentId: partyPlotId,
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

class UIConstants {
  static const String noUserImageUrl = "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png";
}

class AppAssets {
  static const String logo = 'assets/images/logo.png';
  static const String googleLogo = 'assets/images/google.png';
}
