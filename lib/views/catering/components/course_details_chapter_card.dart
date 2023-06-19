import 'package:smart_catering_service/backend/authentication/authentication_provider.dart';
import 'package:smart_catering_service/models/course/data_model/catering_package_model.dart';
import 'package:smart_catering_service/models/course/data_model/party_plot_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../configs/styles.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_text.dart';

class CourseDetailsChapterCard extends StatefulWidget {
  final ChapterModel chapterModel;
  final CourseModel courseModel;
  final String title;
  final bool isLastPlayedChapter;
  final bool isActiveCourse;
  final void Function() onImageTap;

  const CourseDetailsChapterCard({
    Key? key,
    required this.chapterModel,
    required this.courseModel,
    required this.title,
    required this.isLastPlayedChapter,
    required this.isActiveCourse,
    required this.onImageTap,
  }) : super(key: key);

  @override
  State<CourseDetailsChapterCard> createState() => _CourseDetailsChapterCardState();
}

class _CourseDetailsChapterCardState extends State<CourseDetailsChapterCard> {
  late ChapterModel chapterModel;
  String thumbnailUrl = "";

  void initialize({required ChapterModel chapterModel}) {
    this.chapterModel = chapterModel;
    thumbnailUrl = widget.chapterModel.thumbnailUrl;
  }

  @override
  void initState() {
    super.initState();
    initialize(chapterModel: widget.chapterModel);
  }

  @override
  void didUpdateWidget(covariant CourseDetailsChapterCard oldWidget) {
    if (widget.chapterModel != chapterModel) {
      initialize(chapterModel: widget.chapterModel);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        CommonText(
          text: widget.title,
          fontSize: 13,
          color: themeData.textTheme.titleMedium?.color?.withAlpha(200) ?? Colors.grey,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            GestureDetector(
              onTap: () {
                widget.onImageTap();
              },
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 5).copyWith(right: 20),
                color: chapterModel.enabled ? (widget.isLastPlayedChapter ? themeData.primaryColor : null) : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Row(
                    children: [
                      getThumbnailWidget(authenticationProvider: context.read<AuthenticationProvider>()),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CommonText(
                              text: widget.chapterModel.title,
                              maxLines: 2,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              textOverFlow: TextOverflow.ellipsis,
                              color: widget.isLastPlayedChapter ? Colors.white : Colors.black,
                            ),
                            const SizedBox(height: 4),
                            CommonText(
                              text: widget.chapterModel.description,
                              maxLines: 2,
                              textOverFlow: TextOverflow.ellipsis,
                              color: widget.isLastPlayedChapter ? Colors.white : const Color(0xff929292),
                              fontSize: 10,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (chapterModel.enabled && widget.isActiveCourse && chapterModel.url.isNotEmpty)
              Positioned(
                bottom: 0,
                top: 0,
                right: 6,
                child: GestureDetector(
                  onTap: () {

                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.isLastPlayedChapter ? Colors.white : Styles.themeBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.play_arrow, color: widget.isLastPlayedChapter ? Colors.black : Colors.white, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget getThumbnailWidget({required AuthenticationProvider authenticationProvider}) {
    bool isShowThumbnail = chapterModel.url.isNotEmpty && thumbnailUrl.isNotEmpty;
    bool isShowTestButton = chapterModel.url.isEmpty && chapterModel.googleFormUrl.isNotEmpty;

    if(!isShowThumbnail && !isShowTestButton) {
      return const SizedBox();
    }

    Widget child;

    if(isShowThumbnail) {
      child = CommonCachedNetworkImage(
        imageUrl: thumbnailUrl,
        borderRadius: 6,
      );
    }
    else {
      child = Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Image.asset(
            "assets/images/exam.png",
          ),
        ),
      );
    }

    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: child,
      ),
    );
  }
}
