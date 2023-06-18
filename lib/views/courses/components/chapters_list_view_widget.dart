import 'package:smart_catering_service/backend/admin/admin_controller.dart';
import 'package:smart_catering_service/backend/admin/admin_provider.dart';
import 'package:smart_catering_service/backend/authentication/authentication_provider.dart';
import 'package:smart_catering_service/backend/course/course_controller.dart';
import 'package:smart_catering_service/models/course/data_model/chapter_model.dart';
import 'package:smart_catering_service/models/course/data_model/course_model.dart';
import 'package:smart_catering_service/models/user/data_model/user_model.dart';
import 'package:smart_catering_service/utils/my_toast.dart';
import 'package:smart_catering_service/views/common/components/MyCupertinoAlertDialogWidget.dart';
import 'package:smart_catering_service/views/common/components/common_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../backend/navigation/navigation_arguments.dart';
import '../../../backend/navigation/navigation_controller.dart';
import '../../../backend/navigation/navigation_operation_parameters.dart';
import '../../../backend/navigation/navigation_type.dart';
import '../../../backend/user/user_repository.dart';
import 'course_details_chapter_card.dart';

class ChaptersListView extends StatelessWidget {
  final CourseModel courseModel;

  const ChaptersListView({
    Key? key,
    required this.courseModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: "Chapters",
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        const SizedBox(height: 8,),
        getListView(chapters: courseModel.chapters),
      ],
    );
  }

  Widget getListView({required List<ChapterModel> chapters}) {
    if (chapters.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: Text("No Chapters Available"),
        ),
      );
    }

    return Consumer2<AuthenticationProvider, AdminProvider>(
      builder: (BuildContext context, AuthenticationProvider authenticationProvider, AdminProvider adminProvider, Widget? child) {
        bool isActiveCourse = authenticationProvider.checkIsActiveCourse(
          courseId: courseModel.id,
          now: adminProvider.timeStamp.get()?.toDate(),
        );

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: chapters.length,
          padding: EdgeInsets.zero,
          itemBuilder: (BuildContext context, int index) {
            ChapterModel chapterModel = chapters[index];

            return CourseDetailsChapterCard(
              chapterModel: chapterModel,
              courseModel: courseModel,
              title: " Chapter  ${index + 1} : ",
              isLastPlayedChapter: isActiveCourse &&
                  authenticationProvider.checkIsLastPlayedChapter(
                    courseId: courseModel.id,
                    chapterId: chapterModel.id,
                  ),
              isActiveCourse: isActiveCourse,
              onImageTap: () async {
                UserModel? userModel = authenticationProvider.userModel.get();
                if (userModel == null) {
                  return;
                }

                if(!chapterModel.enabled) {
                  MyToast.showError(context: context, msg: "Chapter Disabled");
                  return;
                }

                String title = "";
                String description = "";
                String positiveText = "";
                bool isEnrollment = false;
                bool isRenewal = false;

                if (!authenticationProvider.checkIsCourseEnrolled(courseId: courseModel.id)) {
                  title = "Course Not Enrolled";
                  description = "You don't have this course enrolled. Do you want to contact admin for enrollment?";
                  positiveText = "Enroll Now";
                  isEnrollment = true;
                } else if (!isActiveCourse) {
                  title = "Course Expired";
                  description = "Your course has been expired. Do you want to contact admin for renewal?";
                  positiveText = "Renew Now";
                  isRenewal = true;
                }

                if (title.isNotEmpty && description.isNotEmpty) {
                  AdminProvider adminProvider = context.read<AdminProvider>();

                  dynamic value = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MyCupertinoAlertDialogWidget(
                        title: title,
                        description: description,
                        neagtiveText: "Cancel",
                        positiveText: positiveText,
                        positiviCallback: () {
                          Navigator.pop(context, true);
                        },
                      );
                    },
                  );

                  if (value == true) {
                    if (isEnrollment) {
                      AdminController(adminProvider: adminProvider).sendEnrollmentRequestInWhatsapp(
                        userName: userModel.name,
                        userMobile: userModel.email,
                        courseName: courseModel.title,
                      );
                    } else if (isRenewal) {
                      AdminController(adminProvider: adminProvider).sendRenewalRequestInWhatsapp(
                        userName: userModel.name,
                        userMobile: userModel.email,
                        courseName: courseModel.title,
                      );
                    }
                  }

                  return;
                }

                if(chapterModel.url.isNotEmpty) {
                  NavigationController.navigateToCoursePlayerScreen(
                    navigationOperationParameters: NavigationOperationParameters(
                      context: context,
                      navigationType: NavigationType.pushNamed,
                    ),
                    arguments: CoursePlayerScreenNavigationArguments(
                      chapterModel: chapterModel,
                      courseModel: courseModel,
                    ),
                  );
                }
                else if(chapterModel.googleFormUrl.isNotEmpty) {
                  CourseController.launchGoogleFormInCourse(formUrl: chapterModel.googleFormUrl);

                  String userId = authenticationProvider.userId.get();
                  if (userId.isNotEmpty) {
                    UserRepository()
                        .updateLastChapterPlayedInCourseForUser(
                      userId: userId,
                      courseId: courseModel.id,
                      chapterId: chapterModel.id,
                    )
                        .then(
                          (bool isUpdated) {
                        authenticationProvider.updateLastChapterPlayedInCourseForUser(
                          courseId: courseModel.id,
                          chapterId: chapterModel.id,
                        );
                      },
                    );
                  }
                }
              },
            );
          },
        );
      },
    );
  }
}
