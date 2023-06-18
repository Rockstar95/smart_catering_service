import 'package:smart_catering_service/models/course/data_model/course_model.dart';
import 'package:smart_catering_service/models/user/data_model/user_course_enrollment_model.dart';
import 'package:smart_catering_service/models/user/data_model/user_model.dart';
import 'package:smart_catering_service/utils/date_representation.dart';
import 'package:smart_catering_service/views/common/components/common_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/admin/admin_controller.dart';
import '../../../backend/admin/admin_provider.dart';
import '../../../configs/styles.dart';

class ChaptersCountAndExpiryDataWidget extends StatelessWidget {
  final CourseModel courseModel;
  final UserModel? userModel;

  const ChaptersCountAndExpiryDataWidget({
    Key? key,
    required this.courseModel,
    required this.userModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Card(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_circle_outline,size: 16,color: Styles.themeEditOrange),
                      const SizedBox(width: 5),
                      CommonText(
                        text: "Chapters",
                        color: Styles.themeEditOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  SizedBox(height: 5,),
                  CommonText(
                    text: "${courseModel.chapters.length}",
                    color: Styles.themeEditOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ],
              ),
            ),
            Container(
              height: 30,
              width: 1,
              color: Colors.black,
            ),
            Expanded(
              child: getCourseEnrollmentWidget(
                courseModel: courseModel,
                userModel: userModel,
                themeData: themeData,
                adminProvider: context.read<AdminProvider>(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCourseEnrollmentWidget({required CourseModel courseModel, required UserModel? userModel, required ThemeData themeData, required AdminProvider adminProvider}) {
    if(userModel == null) {
      return const Text("No Data");
    }

    UserCourseEnrollmentModel? userCourseEnrollmentModel = userModel.myCoursesData[courseModel.id];
    bool isCourseEnrolled = userCourseEnrollmentModel != null;

    if(!isCourseEnrolled) {
      return Column(
        children: [
          TextButton(
            onPressed: () {
              AdminController(adminProvider: adminProvider).sendEnrollmentRequestInWhatsapp(
                userName: userModel.name,
                userMobile: userModel.email,
                courseName: courseModel.title,
              );
            },
            child: Text(
              "Enroll Now",
              style: themeData.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: themeData.primaryColor,
              ),
            ),
          ),
        ],
      );
    }

    DateTime? expiryDate = userCourseEnrollmentModel.expiryDate?.toDate();
    DateTime? now = adminProvider.timeStamp.get()?.toDate();
    int remainingDays = -1;
    if(expiryDate != null && now != null && expiryDate.isAfter(now)) {
      remainingDays = DatePresentation.getDifferenceBetweenDatesInDays(expiryDate, now);
    }
    bool isActive = remainingDays > -1;

    if(isActive) {
      Color activeColor = Colors.green;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timelapse,
                color: activeColor,
                 size: 16,
              ),
              const SizedBox(width: 5),
              CommonText(
                text: "Active",
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: activeColor,

              ),
            ],
          ),
          SizedBox(height: 5,),
          CommonText(
            text: "$remainingDays Days",
            color: activeColor,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ],
      );
    }
    else {
      Color expiryColor = Colors.red;
      return GestureDetector(
        onTap: () {
          AdminController(adminProvider: adminProvider).sendRenewalRequestInWhatsapp(
            userName: userModel.name,
            userMobile: userModel.email,
            courseName: courseModel.title,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.running_with_errors,
                  color: expiryColor,
                  size: 22,
                ),
                const SizedBox(width: 5),
                CommonText(
                  text: " Expired",
                  color: expiryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ],
            ),
          ],
        ),
      );
    }
  }
}
