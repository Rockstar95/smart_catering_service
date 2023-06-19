import 'package:smart_catering_service/models/course/data_model/party_plot_model.dart';
import 'package:smart_catering_service/models/user/data_model/user_model.dart';
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
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline,size: 16,color: Styles.themeEditOrange),
                      SizedBox(width: 5),
                      CommonText(
                        text: "Chapters",
                        color: Styles.themeEditOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ],
                  ),
                  const SizedBox(height: 5,),
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
}
