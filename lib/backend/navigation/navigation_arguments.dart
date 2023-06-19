import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';

import '../../models/user/data_model/user_model.dart';

class NavigationArguments {
  const NavigationArguments();
}

class OtpScreenNavigationArguments extends NavigationArguments {
  final String mobile;

  const OtpScreenNavigationArguments({
    required this.mobile,
  });
}

class EditProfileScreenNavigationArguments extends NavigationArguments {
  final UserModel userModel;
  final bool isSignUp;

  const EditProfileScreenNavigationArguments({
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
