import 'package:smart_catering_service/models/admin_user/data_model/admin_user_model.dart';
import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';

import '../../models/user/data_model/user_model.dart';
import '../../views/catering/screens/add_edit_admin_catering_screen.dart';

class NavigationArguments {
  const NavigationArguments();
}

class OtpScreenNavigationArguments extends NavigationArguments {
  final String mobile;

  const OtpScreenNavigationArguments({
    required this.mobile,
  });
}

class AdminRegistrationScreenNavigationArguments extends NavigationArguments {
  final AdminUserModel adminUserModel;

  const AdminRegistrationScreenNavigationArguments({
    required this.adminUserModel,
  });
}

class UserEditProfileScreenNavigationArguments extends NavigationArguments {
  final UserModel userModel;
  final bool isSignUp;

  const UserEditProfileScreenNavigationArguments({
    required this.userModel,
    this.isSignUp = false,
  });
}

class CateringDetailsScreenNavigationArguments extends NavigationArguments {
  final CateringModel cateringModel;

  const CateringDetailsScreenNavigationArguments({
    required this.cateringModel,
  });
}

class AddEditAdminCateringPackageScreenNavigationArguments extends NavigationArguments {
  final CateringPackageModelTemp? cateringPackageModelTemp;

  const AddEditAdminCateringPackageScreenNavigationArguments({
    required this.cateringPackageModelTemp,
  });
}
