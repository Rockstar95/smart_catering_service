import 'package:smart_catering_service/models/course/data_model/chapter_model.dart';
import 'package:smart_catering_service/models/course/data_model/course_model.dart';
import 'package:smart_catering_service/utils/extensions.dart';
import 'package:smart_catering_service/utils/my_safe_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../backend/authentication/authentication_provider.dart';
import '../../../configs/styles.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_text.dart';

class CoursePlayerChapterCard extends StatefulWidget {
  final ChapterModel chapterModel;
  final CourseModel courseModel;
  final bool isCurrentChapterPlaying;
  final void Function({required ChapterModel chapterModel}) onChapterChanged;
  final Widget buttonChild;

  const CoursePlayerChapterCard({
    Key? key,
    required this.chapterModel,
    required this.courseModel,
    required this.isCurrentChapterPlaying,
    required this.onChapterChanged,
    required this.buttonChild,
  }) : super(key: key);

  @override
  State<CoursePlayerChapterCard> createState() => _CoursePlayerChapterCardState();
}

class _CoursePlayerChapterCardState extends State<CoursePlayerChapterCard> with MySafeState {
  late ChapterModel chapterModel;
  String thumbnailUrl = "";

  void initialize({required ChapterModel chapterModel}) {
    this.chapterModel = chapterModel;
    String? videoId = YoutubePlayer.convertUrlToId(widget.chapterModel.url);
    thumbnailUrl = videoId.checkNotEmpty ? YoutubePlayer.getThumbnail(videoId: videoId!) : widget.chapterModel.thumbnailUrl;
  }

  @override
  void initState() {
    super.initState();
    initialize(chapterModel: widget.chapterModel);
  }

  @override
  void didUpdateWidget(covariant CoursePlayerChapterCard oldWidget) {
    if (widget.chapterModel != chapterModel) {
      initialize(chapterModel: widget.chapterModel);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        GestureDetector(
          onTap: () {
            widget.onChapterChanged(chapterModel: chapterModel);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 5).copyWith(right: 20),
            color: chapterModel.enabled ? (widget.isCurrentChapterPlaying ? themeData.primaryColor : null) : Colors.grey,
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
                            color: widget.isCurrentChapterPlaying ? Colors.white : Colors.black),
                        const SizedBox(height: 4),
                        CommonText(
                          text: widget.chapterModel.description,
                          maxLines: 2,
                          textOverFlow: TextOverflow.ellipsis,
                          color: widget.isCurrentChapterPlaying ? Colors.white : const Color(0xff929292),
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
        if (chapterModel.enabled && chapterModel.url.isNotEmpty)
          Positioned(
            bottom: 0,
            top: 0,
            right: 6,
            child: GestureDetector(
              onTap: () {
                widget.onChapterChanged(chapterModel: chapterModel);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isCurrentChapterPlaying ? Colors.white : Styles.themeBlue,
                ),
                child: widget.buttonChild,
              ),
            ),
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
      child = AspectRatio(
        aspectRatio: 16 / 9,
        child: CommonCachedNetworkImage(
          imageUrl: thumbnailUrl,
          borderRadius: 6,
        ),
      );
    }
    else {
      child = AspectRatio(
        aspectRatio: 16 / 9,
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
      child: Row(
        children: [
          Flexible(child: child),
        ],
      ),
    );
  }
}
