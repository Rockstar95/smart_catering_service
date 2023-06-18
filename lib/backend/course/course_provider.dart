import '../../configs/typedefs.dart';
import '../../models/course/data_model/course_model.dart';
import '../common/common_provider.dart';

class CourseProvider extends CommonProvider {
  CourseProvider() {
    courses = CommonProviderListParameter<CourseModel>(
      list: [],
      notify: notify,
    );
    lastCourseDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreCourses = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isCoursesFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isCoursesLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );

    myCourses = CommonProviderListParameter<CourseModel>(
      list: [],
      notify: notify,
    );
    isMyCoursesFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    userId = CommonProviderPrimitiveParameter<String>(
      value: "",
      notify: notify,
    );
  }

  //region Courses Paginated List
  late CommonProviderListParameter<CourseModel> courses;
  int get coursesLength => courses.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastCourseDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreCourses;
  late CommonProviderPrimitiveParameter<bool> isCoursesFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isCoursesLoading;
  //endregion

  //region My Courses List
  late CommonProviderListParameter<CourseModel> myCourses;
  int get myCoursesLength => myCourses.getList(isNewInstance: false).length;

  late CommonProviderPrimitiveParameter<bool> isMyCoursesFirstTimeLoading;
  late CommonProviderPrimitiveParameter<String> userId;
  //endregion

  void reset({bool isNotify = true}) {
    courses.setList(list: [], isNotify: false);
    lastCourseDocument.set(value: null, isNotify: false);
    hasMoreCourses.set(value: true, isNotify: false);
    isCoursesFirstTimeLoading.set(value: false, isNotify: false);
    isCoursesLoading.set(value: false, isNotify: false);

    myCourses.setList(list: [], isNotify: false);
    isCoursesFirstTimeLoading.set(value: false, isNotify: false);
    userId.set(value: "", isNotify: isNotify);
  }
}