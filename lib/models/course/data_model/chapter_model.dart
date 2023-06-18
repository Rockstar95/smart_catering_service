import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class ChapterModel {
  String id = "";
  String title = "";
  String description = "";
  String url = "";
  String thumbnailUrl = "";
  String googleFormUrl = "";
  bool enabled = false;

  ChapterModel({
    this.id = "",
    this.title = "",
    this.description = "",
    this.url = "",
    this.thumbnailUrl = "",
    this.googleFormUrl = "",
    this.enabled = false,
  });

  ChapterModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    title = ParsingHelper.parseStringMethod(map['title']);
    description = ParsingHelper.parseStringMethod(map['description']);
    url = ParsingHelper.parseStringMethod(map['url']);
    thumbnailUrl = ParsingHelper.parseStringMethod(map['thumbnailUrl']);
    googleFormUrl = ParsingHelper.parseStringMethod(map['googleFormUrl']);
    enabled = ParsingHelper.parseBoolMethod(map['enabled']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "title" : title,
      "description" : description,
      "url" : url,
      "thumbnailUrl" : thumbnailUrl,
      "googleFormUrl" : googleFormUrl,
      "enabled" : enabled,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}