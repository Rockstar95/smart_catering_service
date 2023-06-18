import '../../models/user/data_model/user_model.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import '../authentication/authentication_provider.dart';
import 'user_repository.dart';

class UserController {
  late AuthenticationProvider _authenticationProvider;
  late UserRepository _userRepository;

  UserController({
    AuthenticationProvider? authenticationProvider,
    UserRepository? repository,
  }) {
    _authenticationProvider = authenticationProvider ?? AuthenticationProvider();
    _userRepository = repository ?? UserRepository();
  }

  AuthenticationProvider get authenticationProvider => _authenticationProvider;

  UserRepository get userRepository => _userRepository;

  Future<bool> createNewUser({required UserModel userModel}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("UserController().createNewUser() called with userModel:'$userModel'", tag: tag);

    bool isCreated = false;

    try {
      isCreated = await userRepository.createNewUser(userModel: userModel);
    } catch (e, s) {
      MyPrint.printOnConsole("Error in Creating User Document in UserController().createNewUser():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
    }

    MyPrint.printOnConsole("isCreated:'$isCreated'", tag: tag);

    return isCreated;
  }
}
