import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';
import 'chapter_model.dart';

class CourseModel {
  String id = "";
  String title = "";
  String description = "";
  String coursePreviewUrl = "";
  String thumbnailUrl = "";
  String backgroundColor = "";
  bool enabled = true;
  Timestamp? createdTime;
  Timestamp? updatedTime;
  List<ChapterModel> chapters = <ChapterModel>[];

  CourseModel({
    this.id = "",
    this.title = "",
    this.description = "",
    this.coursePreviewUrl = "",
    this.thumbnailUrl = "",
    this.backgroundColor = "",
    this.enabled = true,
    this.createdTime,
    this.updatedTime,
    List<ChapterModel>? chapters,
  }) {
    this.chapters = chapters ?? <ChapterModel>[];
  }

  CourseModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    title = ParsingHelper.parseStringMethod(map['title']);
    description = ParsingHelper.parseStringMethod(map['description']);
    coursePreviewUrl = ParsingHelper.parseStringMethod(map['coursePreviewUrl']);
    thumbnailUrl = ParsingHelper.parseStringMethod(map['thumbnailUrl']);
    backgroundColor = ParsingHelper.parseStringMethod(map['backgroundColor']);
    enabled = ParsingHelper.parseBoolMethod(map['enabled']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);

    chapters.clear();
    List<Map<String, dynamic>> chaptersMapsList = ParsingHelper.parseMapsListMethod<String, dynamic>(map['chapters']);
    chapters.addAll(chaptersMapsList.map((e) {
      return ChapterModel.fromMap(e);
    }).toList());
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "title" : title,
      "description" : description,
      "coursePreviewUrl" : coursePreviewUrl,
      "thumbnailUrl" : thumbnailUrl,
      "backgroundColor" : backgroundColor,
      "enabled" : enabled,
      "createdTime" : createdTime,
      "updatedTime" : updatedTime,
      "chapters" : chapters.map((e) => e.toMap(toJson: toJson)).toList(),
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}