import 'package:smart_catering_service/backend/admin/admin_controller.dart';
import 'package:smart_catering_service/backend/admin/admin_provider.dart';
import 'package:smart_catering_service/backend/authentication/authentication_provider.dart';
import 'package:smart_catering_service/backend/course/catering_controller.dart';
import 'package:smart_catering_service/models/course/data_model/catering_package_model.dart';
import 'package:smart_catering_service/models/course/data_model/party_plot_model.dart';
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
        const CommonText(
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
        bool isActiveCourse = true;

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
              isLastPlayedChapter: isActiveCourse && false,
              isActiveCourse: isActiveCourse,
              onImageTap: () async {

              },
            );
          },
        );
      },
    );
  }
}
