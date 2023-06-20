import 'package:smart_catering_service/models/admin_user/data_model/admin_user_model.dart';
import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';

import '../../models/admin_user/request_model/admin_user_update_request_model.dart';
import '../../models/party_plot/data_model/party_plot_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../authentication/authentication_provider.dart';
import 'admin_user_provider.dart';
import 'admin_user_repository.dart';

class AdminUserController {
  late AuthenticationProvider _authenticationProvider;
  late AdminUserProvider _adminUserProvider;
  late AdminUserRepository _adminUserRepository;

  AdminUserController({
    AuthenticationProvider? authenticationProvider,
    AdminUserProvider? adminUserProvider,
    AdminUserRepository? repository,
  }) {
    _authenticationProvider = authenticationProvider ?? AuthenticationProvider();
    _adminUserProvider = adminUserProvider ?? AdminUserProvider();
    _adminUserRepository = repository ?? AdminUserRepository();
  }

  AuthenticationProvider get authenticationProvider => _authenticationProvider;

  AdminUserProvider get adminUserProvider => _adminUserProvider;

  AdminUserRepository get adminUserRepository => _adminUserRepository;

  Future<bool> createNewUser({required AdminUserModel userModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserController().createNewUser() called with userModel:'$userModel'", tag: tag);

    bool isCreated = false;

    try {
      isCreated = await adminUserRepository.createNewUser(userModel: userModel);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in AdminUserController().createNewUser():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isCreated:'$isCreated'", tag: tag);

    return isCreated;
  }

  Future<bool> updateAdminUserDetails({required AdminUserUpdateRequestModel requestModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserController().updateProfileDetails() called with requestModel:'$requestModel'", tag: tag);

    bool isUpdated = false;

    try {
      isUpdated = await adminUserRepository.updateAdminUserDetails(requestModel: requestModel);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in AdminUserController().updateProfileDetails():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isUpdated:'$isUpdated'", tag: tag);

    return isUpdated;
  }

  Future<void> initializeCateringModel({required String cateringId}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserController().initializeCateringModel() called", tag: tag);

    try {
      CateringModel? cateringModel = await adminUserRepository.getCateringModelFromId(id: cateringId);
      MyPrint.printOnConsole("cateringModel:$cateringModel", tag: tag);

      adminUserProvider.cateringModel.set(value: cateringModel ?? CateringModel(), isNewInstance: false);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminUserController().initializeCateringModel():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<void> initializePartyPlotModel({required String partyPlotId}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserController().initializePartyPlotModel() called", tag: tag);

    try {
      PartyPlotModel? partyPlotModel = await adminUserRepository.getPartyPlotModelFromId(id: partyPlotId);
      MyPrint.printOnConsole("partyPlotModel:$partyPlotModel", tag: tag);

      adminUserProvider.partyPlotModel.set(value: partyPlotModel ?? PartyPlotModel(), isNewInstance: false);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminUserController().initializePartyPlotModel():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }
  }

  Future<bool> updateCateringModel({required String cateringId, required CateringModel cateringModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("AdminUserController().initializeCateringModel() called", tag: tag);

    try {
      bool isSet = await adminUserRepository.setCateringModelInId(id: cateringId, cateringModel: cateringModel);
      MyPrint.printOnConsole("isSet:$isSet", tag: tag);

      if(isSet) {
        adminUserProvider.cateringModel.set(value: cateringModel, isNewInstance: true);
      }

      return isSet;
    } catch (e, s) {
      MyPrint.printOnConsole("Error in AdminUserController().initializeCateringModel():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    return false;
  }
}
