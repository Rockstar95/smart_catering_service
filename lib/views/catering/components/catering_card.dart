import 'package:flutter/material.dart';
import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';
import 'package:smart_catering_service/views/catering/screens/catering_detail.dart';

import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_text.dart';

class CateringCard extends StatelessWidget {
  final CateringModel cateringModel;

  const CateringCard({
    Key? key,
    required this.cateringModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MyPrint.printOnConsole("courseModel.thumbnailUrl:${courseModel.thumbnailUrl}");

    ThemeData themeData = Theme.of(context);

    return GestureDetector(
      onTap: () {
  Navigator.push(context, MaterialPageRoute(builder: (ctx)=>Catering_details(cateringModel: cateringModel)));
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
                      imageUrl: cateringModel.thumbnailUrl,
                      borderRadius: 5,
                    ),
                  ),
                  const SizedBox(height: 10),
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
                    text: cateringModel.title,
                    maxLines: 1,
                    fontWeight: FontWeight.bold,
                    height: .6,
                    fontSize: 21,
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    text: cateringModel.description,
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
  }
}
