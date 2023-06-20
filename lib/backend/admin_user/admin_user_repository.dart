import 'package:smart_catering_service/models/admin_user/data_model/admin_user_model.dart';
import 'package:smart_catering_service/models/admin_user/request_model/admin_user_update_request_model.dart';
import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../models/common/data_model/new_document_data_model.dart';
import '../../models/party_plot/data_model/party_plot_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';

class AdminUserRepository {
  Future<AdminUserModel?> getAdminUserModelFromId({required String userId}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserRepository().getAdminUserModelFromId() called with userId:'$userId'", tag: tag);

    if (userId.isEmpty) {
      MyPrint.printOnConsole("Returning from AdminUserRepository().getAdminUserModelFromId() because userId is empty", tag: tag);
      return null;
    }

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.adminUserDocumentReference(userId: userId).get();
      MyPrint.printOnConsole("snapshot.exists:'${snapshot.exists}'", tag: tag);
      MyPrint.printOnConsole("snapshot.data():'${snapshot.data()}'", tag: tag);

      if (snapshot.exists && (snapshot.data()?.isNotEmpty ?? false)) {
        return AdminUserModel.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminUserRepository().getAdminUserModelFromId():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return null;
    }
  }

  Future<bool> createNewUser({required AdminUserModel userModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserRepository().createNewUser() called with userModel:'$userModel'", tag: tag);

    if (userModel.id.isEmpty) {
      MyPrint.printOnConsole("Returning from AdminUserRepository().createNewUser() because userId is empty", tag: tag);
      return false;
    }

    bool isCreated = false;

    try {
      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      MyPrint.printOnConsole("newDocumentDataModel:'$newDocumentDataModel'", tag: tag);

      userModel.createdTime = newDocumentDataModel.timestamp;

      MyPrint.printOnConsole("Final userModel:'$userModel'", tag: tag);

      await FirebaseNodes.adminUserDocumentReference(userId: userModel.id).set(userModel.toMap());
      isCreated = true;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in Firestore in AdminUserRepository().createNewUser():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isCreated:'$isCreated'", tag: tag);

    return isCreated;
  }

  Future<bool> updateAdminUserDetails({required AdminUserUpdateRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserRepository().updateAdminUserDetails() called with requestModel:'$requestModel'", tag: tag);

    if (requestModel.id.isEmpty) {
      MyPrint.printOnConsole("Returning from AdminUserRepository().updateAdminUserDetails() because userId is empty", tag: tag);
      return false;
    }

    bool isUpdated = false;

    try {
      NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
      MyPrint.printOnConsole("newDocumentDataModel:'$newDocumentDataModel'", tag: tag);

      requestModel.updatedTime = newDocumentDataModel.timestamp;

      MyPrint.printOnConsole("Final requestModel:'$requestModel'", tag: tag);

      await FirebaseNodes.adminUserDocumentReference(userId: requestModel.id).update(requestModel.toMap());
      isUpdated = true;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in Firestore in AdminUserRepository().updateAdminUserDetails():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isUpdated:'$isUpdated'", tag: tag);

    return isUpdated;
  }

  Future<CateringModel?> getCateringModelFromId({required String id}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserRepository().getCateringModelFromId() called with id:'$id'", tag: tag);

    if (id.isEmpty) {
      MyPrint.printOnConsole("Returning from AdminUserRepository().getCateringModelFromId() because id is empty", tag: tag);
      return null;
    }

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.cateringDocumentReference(cateringId: id).get();
      MyPrint.printOnConsole("snapshot.exists:'${snapshot.exists}'", tag: tag);
      MyPrint.printOnConsole("snapshot.data():'${snapshot.data()}'", tag: tag);

      if (snapshot.exists && (snapshot.data()?.isNotEmpty ?? false)) {
        return CateringModel.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminUserRepository().getCateringModelFromId():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return null;
    }
  }

  Future<PartyPlotModel?> getPartyPlotModelFromId({required String id}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserRepository().getPartyPlotModelFromId() called with id:'$id'", tag: tag);

    if (id.isEmpty) {
      MyPrint.printOnConsole("Returning from AdminUserRepository().getPartyPlotModelFromId() because id is empty", tag: tag);
      return null;
    }

    try {
      MyFirestoreDocumentSnapshot snapshot = await FirebaseNodes.partyPlotDocumentReference(partyPlotId: id).get();
      MyPrint.printOnConsole("snapshot.exists:'${snapshot.exists}'", tag: tag);
      MyPrint.printOnConsole("snapshot.data():'${snapshot.data()}'", tag: tag);

      if (snapshot.exists && (snapshot.data()?.isNotEmpty ?? false)) {
        return PartyPlotModel.fromMap(snapshot.data()!);
      } else {
        return null;
      }
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminUserRepository().getPartyPlotModelFromId():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return null;
    }
  }

  Future<bool> setCateringModelInId({required String id, required CateringModel cateringModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserRepository().setCateringModelInId() called with id:'$id', cateringModel:'$cateringModel'", tag: tag);

    if (id.isEmpty) {
      MyPrint.printOnConsole("Returning from AdminUserRepository().setCateringModelInId() because id is empty", tag: tag);
      return false;
    }

    NewDocumentDataModel newDocumentDataModel = await MyUtils.getNewDocIdAndTimeStamp(isGetTimeStamp: true);
    if(cateringModel.id.isEmpty) {
      cateringModel.id = id;
      cateringModel.createdTime = newDocumentDataModel.timestamp;
    }
    else {
      cateringModel.updatedTime = newDocumentDataModel.timestamp;
    }
    if(cateringModel.createdTime == null) {
      cateringModel.createdTime = newDocumentDataModel.timestamp;
    }

    try {
      await FirebaseNodes.cateringDocumentReference(cateringId: cateringModel.id).set(cateringModel.toMap());
      MyPrint.printOnConsole("Catering Document Updated", tag: tag);

      return true;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminUserRepository().setCateringModelInId():'$e'", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      return false;
    }
  }
}
