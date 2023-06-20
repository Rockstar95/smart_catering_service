import 'package:smart_catering_service/models/admin_user/data_model/admin_user_model.dart';

import '../../models/admin_user/request_model/admin_user_update_request_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../authentication/authentication_provider.dart';
import 'admin_user_repository.dart';

class AdminUserController {
  late AuthenticationProvider _authenticationProvider;
  late AdminUserRepository _adminUserRepository;

  AdminUserController({
    AuthenticationProvider? authenticationProvider,
    AdminUserRepository? repository,
  }) {
    _authenticationProvider = authenticationProvider ?? AuthenticationProvider();
    _adminUserRepository = repository ?? AdminUserRepository();
  }

  AuthenticationProvider get authenticationProvider => _authenticationProvider;

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
    MyPrint.printOnConsole("UserController().updateProfileDetails() called with requestModel:'$requestModel'", tag: tag);

    bool isUpdated = false;

    try {
      isUpdated = await adminUserRepository.updateAdminUserDetails(requestModel: requestModel);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in UserController().updateProfileDetails():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isUpdated:'$isUpdated'", tag: tag);

    return isUpdated;
  }
}
