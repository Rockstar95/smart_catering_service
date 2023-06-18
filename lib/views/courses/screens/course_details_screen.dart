import 'package:smart_catering_service/backend/authentication/authentication_provider.dart';
import 'package:smart_catering_service/backend/navigation/navigation_arguments.dart';
import 'package:smart_catering_service/models/course/data_model/course_model.dart';
import 'package:smart_catering_service/utils/extensions.dart';
import 'package:smart_catering_service/utils/my_safe_state.dart';
import 'package:smart_catering_service/utils/my_toast.dart';
import 'package:smart_catering_service/views/common/components/common_cachednetwork_image.dart';
import 'package:smart_catering_service/views/common/components/common_read_more_text.dart';
import 'package:smart_catering_service/views/common/components/common_text.dart';
import 'package:smart_catering_service/views/common/components/my_youtube_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../configs/styles.dart';
import '../../common/components/my_youtube_player_builder.dart';
import '../components/chapters_count_and_expiry_data_widget.dart';
import '../components/chapters_list_view_widget.dart';

class CourseDetailsScreen extends StatefulWidget {
  static const String routeName = "/CourseDetailsScreen";

  final CourseDetailsScreenNavigationArguments arguments;

  const CourseDetailsScreen({
    Key? key,
    required this.arguments,
  }) : super(key: key);

  @override
  State<CourseDetailsScreen> createState() => _CourseDetailsScreenState();
}

class _CourseDetailsScreenState extends State<CourseDetailsScreen> with MySafeState {
  bool isPlayVideo = false;

  YoutubePlayerController? youtubePlayerController;

  @override
  void initState() {
    super.initState();

    CourseModel model = widget.arguments.courseModel;
    if (model.coursePreviewUrl.checkNotEmpty) {
      String? videoId = YoutubePlayer.convertUrlToId(model.coursePreviewUrl);
      if (videoId.checkNotEmpty) {
        if (youtubePlayerController == null) {
          youtubePlayerController = YoutubePlayerController(
            initialVideoId: videoId!,
            flags: const YoutubePlayerFlags(
              autoPlay: true,
              mute: false,
              forceHD: true,
            ),
          );
        } else {
          youtubePlayerController!.load(videoId!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    CourseModel model = widget.arguments.courseModel;

    return Consumer<AuthenticationProvider>(
      builder: (BuildContext context, AuthenticationProvider authenticationProvider, Widget? child) {
        return Scaffold(
          backgroundColor: Styles.themeBgColor,
          body: getMainBody(
            courseModel: model,
            authenticationProvider: authenticationProvider,
          ),
        );
      },
    );
  }

  Widget getMainBody({required CourseModel courseModel, required AuthenticationProvider authenticationProvider}) {
    if (youtubePlayerController != null) {
      return MyYoutubePlayerBuilder(
        player: MyYoutubePlayer(
          controller: youtubePlayerController!,
          showVideoProgressIndicator: true,
          progressIndicatorColor: themeData.primaryColor,
          progressColors: ProgressBarColors(
            playedColor: themeData.primaryColor,
            handleColor: themeData.colorScheme.secondary,
          ),
          onReady: () {
            // youtubePlayerController!.addListener(listener);
          },
        ),
        builder: (BuildContext context, Widget player) {
          return getBody(
            courseModel: courseModel,
            authenticationProvider: authenticationProvider,
            player: player,
          );
        },
        onEnterFullScreen: () {},
        onExitFullScreen: () {
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        },
      );
    } else {
      return getBody(
        courseModel: courseModel,
        authenticationProvider: authenticationProvider,
        player: null,
      );
    }
  }

  Widget getBody({required CourseModel courseModel, required AuthenticationProvider authenticationProvider, required Widget? player}) {
    return SafeArea(
      top: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          getMyTopBar(),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: getCourseImageWidget(
              thumbnailImageUrl: courseModel.thumbnailUrl,
              coursePreviewUrl: courseModel.coursePreviewUrl,
              player: player,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    ChaptersCountAndExpiryDataWidget(
                      courseModel: courseModel,
                      userModel: authenticationProvider.userModel.get(),
                    ),
                    const SizedBox(height: 10),
                    getCourseBasicData(model: courseModel),
                    const SizedBox(height: 20),
                    ChaptersListView(courseModel: courseModel),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getPlayerWidget({required Widget? player}) {
    if (player == null) {
      return Expanded(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(.3),
          ),
          child: Center(
            child: CommonText(text: "Error in Playing video", fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
          ),
        ),
      );
    }

    return player;
  }

  Widget getMyTopBar() {
    return Container(
      height: 100,
      width: double.maxFinite,
      color: Styles.themeBlue,
      child: SizedBox(
        height: 35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(5),
                margin: const EdgeInsets.only(left: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: Styles.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 23),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getCourseImageWidget({required String thumbnailImageUrl, required String coursePreviewUrl, required Widget? player}) {
    if (isPlayVideo && player != null) {
      return player;
    }

    return InkWell(
      onTap: () {
        if (coursePreviewUrl.isNotEmpty) {
          isPlayVideo = true;
          mySetState();
        } else {
          MyToast.showError(context: context, msg: 'Some error in fetching video! Please try again later');
        }
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CommonCachedNetworkImage(imageUrl: thumbnailImageUrl),
            Container(
                // height: 180,
                // width: double.maxFinite,
                color: Colors.black.withOpacity(.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Styles.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.black, size: 30),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    CommonText(
                      text: 'Preview',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }

  Widget getCourseBasicData({required CourseModel model}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonReadMoreTextWidget(
          text: model.title,
          trimLines: 3,
          textStyle: themeData.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 6),
        CommonReadMoreTextWidget(
          text: model.description,
          trimLines: 8,
          textStyle: themeData.textTheme.bodyMedium?.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}
