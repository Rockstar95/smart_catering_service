import 'package:smart_catering_service/backend/navigation/navigation_arguments.dart';
import 'package:smart_catering_service/backend/navigation/navigation_controller.dart';
import 'package:smart_catering_service/backend/navigation/navigation_operation_parameters.dart';
import 'package:smart_catering_service/backend/navigation/navigation_type.dart';
import 'package:smart_catering_service/views/common/components/common_submit_button.dart';
import 'package:smart_catering_service/views/common/components/common_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/admin/admin_controller.dart';
import '../../../backend/admin/admin_provider.dart';
import '../../../backend/authentication/authentication_provider.dart';
import '../../../configs/styles.dart';
import '../../../models/course/data_model/course_model.dart';
import '../../../models/user/data_model/user_course_enrollment_model.dart';
import '../../../models/user/data_model/user_model.dart';
import '../../../utils/date_representation.dart';
import '../../common/components/common_cachednetwork_image.dart';

class AllCourseCard extends StatelessWidget {
  final CourseModel courseModel;

  const AllCourseCard({
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
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              color: themeData.colorScheme.onPrimary,
              borderRadius: BorderRadius.circular(7),
              boxShadow: [
                BoxShadow(
                  blurRadius: 25,
                  offset: const Offset(0, 0),
                  spreadRadius: 0,
                  color: Colors.black.withOpacity(0.12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15).copyWith(bottom: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CommonCachedNetworkImage(
                          imageUrl: courseModel.thumbnailUrl,
                          borderRadius: 5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: getChapterCountWidget(chaptersLength: courseModel.chapters.length, themeData: themeData)),
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
                const SizedBox(height: 7),
                Container(
                  color: Colors.grey.withOpacity(0.2),
                  height: 0.6,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                       text:  courseModel.title,
                        maxLines: 1,
                      fontWeight: FontWeight.bold,
                      height: .6,
                      fontSize: 21
                      ),
                      const SizedBox(height: 8),
                      CommonText(
                        text: courseModel.description,
                        maxLines: 2,
                        textOverFlow: TextOverflow.ellipsis,
                        color: const Color(0xff929292),
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget getChapterCountWidget({required int chaptersLength, required ThemeData themeData}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.play_circle_outline,
          size: 20,
          color: Styles.themeEditOrange,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: CommonText(
            text: "$chaptersLength Chapters",
            color: Styles.themeEditOrange,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget getCourseEnrollmentWidget(
      {required CourseModel courseModel, required UserModel? userModel, required ThemeData themeData, required AdminProvider adminProvider}) {
    if (userModel == null) {
      return const Text("No Data");
    }

    UserCourseEnrollmentModel? userCourseEnrollmentModel = userModel.myCoursesData[courseModel.id];
    bool isCourseEnrolled = userCourseEnrollmentModel != null;

    if (!isCourseEnrolled) {
      return CommonSubmitButton(
        onTap: (){
          AdminController(adminProvider: adminProvider).sendEnrollmentRequestInWhatsapp(
            userName: userModel.name,
            userMobile: userModel.email,
            courseName: courseModel.title,
          );
        },
        text: 'Enroll Now',
        fontSize: 11,
        prefixIcon: Icon(Icons.bookmark_border_outlined,size: 17,color: Colors.white,),
        horizontalPadding: 8,
        verticalPadding: 8,
        borderRadius: 5,
      );
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
              size: 20,
            ),
            const SizedBox(width: 5),
            CommonText(
             text:  "Active For $remainingDays Days  ",
              fontSize: 10,
              color: activeColor,
              fontWeight: FontWeight.bold,
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
              color: expiryColor,size: 20,

            ),
            const SizedBox(width: 5),
            CommonText(
              text: "Expired  ",
              fontSize: 10,
              color: expiryColor,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
      );
    }
  }



}
