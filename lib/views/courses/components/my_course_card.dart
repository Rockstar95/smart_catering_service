import 'package:smart_catering_service/backend/navigation/navigation_arguments.dart';
import 'package:smart_catering_service/backend/navigation/navigation_controller.dart';
import 'package:smart_catering_service/backend/navigation/navigation_operation_parameters.dart';
import 'package:smart_catering_service/backend/navigation/navigation_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/admin/admin_provider.dart';
import '../../../backend/authentication/authentication_provider.dart';
import '../../../configs/styles.dart';
import '../../../models/course/data_model/course_model.dart';
import '../../../models/user/data_model/user_course_enrollment_model.dart';
import '../../../models/user/data_model/user_model.dart';
import '../../../utils/date_representation.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_text.dart';

class MyCourseCard extends StatelessWidget {
  final CourseModel courseModel;

  const MyCourseCard({
    Key? key,
    required this.courseModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MyPrint.printOnConsole("courseModel.thumbnailUrl:${courseModel.thumbnailUrl}");

    ThemeData themeData = Theme.of(context);

    return Consumer2<AuthenticationProvider, AdminProvider>(
      builder: (BuildContext context, AuthenticationProvider authenticationProvider, AdminProvider adminProvider, Widget? child) {
        return GestureDetector(
          onTap: () {
            NavigationController.navigateToCourseDetailsScreen(
              navigationOperationParameters: NavigationOperationParameters(
                context: context,
                navigationType: NavigationType.pushNamed,
              ),
              arguments: CourseDetailsScreenNavigationArguments(courseModel: courseModel),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0).copyWith(right: 15),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12).copyWith(right: 25),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 110,
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: CommonCachedNetworkImage(
                            imageUrl: courseModel.thumbnailUrl,
                            borderRadius: 5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              text: courseModel.title,
                              maxLines: 1,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            const SizedBox(height: 4),
                            CommonText(
                              text: courseModel.description,
                              maxLines: 2,
                              textOverFlow: TextOverflow.ellipsis,
                              color: const Color(0xff929292),
                              fontSize: 10,
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: getChapterCountWidget(chaptersLength: courseModel.chapters.length),
                                ),
                                Flexible(
                                  child: getCourseEnrollmentWidget(
                                    themeData: themeData,
                                    userModel: authenticationProvider.userModel.get(),
                                    courseModel: courseModel,
                                    adminProvider: adminProvider,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0,
                  top: 0,
                  right: -15,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Styles.themeBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.black, size: 20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getChapterCountWidget({required int chaptersLength}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.play_circle_outline,
          size: 18,
          color: Styles.themeEditOrange,
        ),
        const SizedBox(width: 3),
        Flexible(
          child: CommonText(
            text: "$chaptersLength Chapters",
            color: Styles.themeEditOrange,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget getCourseEnrollmentWidget({
    required CourseModel courseModel,
    required UserModel? userModel,
    required ThemeData themeData,
    required AdminProvider adminProvider,
  }) {
    if (userModel == null) {
      return const Text("No Data");
    }

    UserCourseEnrollmentModel? userCourseEnrollmentModel = userModel.myCoursesData[courseModel.id];
    bool isCourseEnrolled = userCourseEnrollmentModel != null;

    if (!isCourseEnrolled) {
      return const SizedBox();
    }

    DateTime? expiryDate = userCourseEnrollmentModel.expiryDate?.toDate();
    DateTime? now = adminProvider.timeStamp.get()?.toDate();
    int remainingDays = -1;
    if (expiryDate != null && now != null && expiryDate.isAfter(now)) {
      remainingDays = DatePresentation.getDifferenceBetweenDatesInDays(expiryDate, now);
    }
    bool isActive = remainingDays > -1;

    if (isActive) {
      Color activeColor = const Color(0xff5AA151);
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
        decoration: BoxDecoration(
          color: const Color(0xffEAF8EC),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timelapse,
              color: activeColor,
              size: 14,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: CommonText(
                text: "Active For ${remainingDays}d  ",
                fontSize: 8,
                color: activeColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      Color expiryColor = Colors.red;
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
        decoration: BoxDecoration(
          color: expiryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.running_with_errors,
              color: expiryColor,
              size: 14,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: CommonText(
                text: "Expired  ",
                color: expiryColor,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
  }
}
