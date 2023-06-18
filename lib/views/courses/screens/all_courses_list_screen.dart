import 'package:smart_catering_service/backend/course/course_provider.dart';
import 'package:smart_catering_service/views/common/components/common_text.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../../backend/course/course_controller.dart';
import '../../../configs/constants.dart';
import '../../../configs/styles.dart';
import '../../../models/course/data_model/course_model.dart';
import '../../../utils/my_safe_state.dart';
import '../../common/components/common_top_bar.dart';
import '../../common/components/loading_widget.dart';
import '../components/all_course_card.dart';

class AllCoursesListScreen extends StatefulWidget {
  final CourseProvider courseProvider;

  const AllCoursesListScreen({
    Key? key,
    required this.courseProvider,
  }) : super(key: key);

  @override
  State<AllCoursesListScreen> createState() => _AllCoursesListScreenState();
}

class _AllCoursesListScreenState extends State<AllCoursesListScreen> with MySafeState {
  late CourseProvider courseProvider;
  late CourseController courseController;

  ScrollController scrollController = ScrollController();

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await courseController.getCoursesPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();

    courseProvider = widget.courseProvider;
    courseController = CourseController(provider: courseProvider);

    if (courseProvider.coursesLength == 0 && courseProvider.hasMoreCourses.get()) {
      getData(
        isRefresh: true,
        isFromCache: false,
        isNotify: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CourseProvider>.value(value: courseProvider),
      ],
      child: Consumer<CourseProvider>(
        builder: (BuildContext context, CourseProvider courseProvider, Widget? child) {
          return Scaffold(
            backgroundColor: Styles.themeBgColor,
            body: Column(
              children: [
                const CommonTopBar(title: 'All Courses'),
                Expanded(child: getProductsListWidget(courseProvider: courseProvider)),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget getProductsListWidget({required CourseProvider courseProvider}) {
    if (courseProvider.isCoursesFirstTimeLoading.get()) {
      return const LoadingWidget(
        boxSize: 60,
        loaderSize: 40,
      );
    }

    if (!courseProvider.isCoursesLoading.get() && courseProvider.coursesLength == 0) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              await getData(
                isRefresh: true,
                isFromCache: false,
                isNotify: true,
              );
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              children: [
                SizedBox(height: constraints.maxHeight / 2.05),
                Center(
                  child: CommonText(text: "No Courses Available Currently",fontWeight: FontWeight.bold,fontSize: 17),
                ),
              ],
            ),
          );
        },
      );
    }

    List<CourseModel> courses = courseProvider.courses.getList(isNewInstance: false);

    double? cacheExtent = scrollController.hasClients ? scrollController.position.maxScrollExtent : null;
    // MyPrint.printOnConsole("cacheExtent:$cacheExtent");

    return RefreshIndicator(
      onRefresh: () async {
        await getData(
          isRefresh: true,
          isFromCache: false,
          isNotify: true,
        );
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        cacheExtent: cacheExtent,
        itemCount: courses.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if ((index == 0 && courses.isEmpty) || (index == courses.length)) {
            if (courseProvider.isCoursesLoading.get()) {
              // if(true) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: themeData.primaryColor,
                      size: 40,
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          }

          if (courseProvider.hasMoreCourses.get() && index > (courses.length - AppConstants.coursesRefreshLimitForPagination)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              courseController.getCoursesPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
            });
          }

          CourseModel model = courses[index];

          return AllCourseCard(courseModel: model);
        },
      ),
    );
  }
}
