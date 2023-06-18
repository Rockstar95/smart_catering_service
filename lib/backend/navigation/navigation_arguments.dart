import 'package:smart_catering_service/models/course/data_model/chapter_model.dart';
import 'package:smart_catering_service/models/course/data_model/course_model.dart';

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

class CourseDetailsScreenNavigationArguments extends NavigationArguments {
  final CourseModel courseModel;

  const CourseDetailsScreenNavigationArguments({
    required this.courseModel,
  });
}

class CoursePlayerScreenNavigationArguments extends NavigationArguments {
  final ChapterModel chapterModel;
  final CourseModel courseModel;

  const CoursePlayerScreenNavigationArguments({
    required this.chapterModel,
    required this.courseModel,
  });
}
