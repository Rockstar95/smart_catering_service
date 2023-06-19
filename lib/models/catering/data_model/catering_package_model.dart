import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class CateringPackageModel {
  String id = "";
  String title = "";
  String description = "";
  String thumbnailUrl = "";
  bool enabled = false;
  double price = 0;

  CateringPackageModel({
    this.id = "",
    this.title = "",
    this.description = "",
    this.thumbnailUrl = "",
    this.enabled = false,
    this.price = 0,
  });

  CateringPackageModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    title = ParsingHelper.parseStringMethod(map['title']);
    description = ParsingHelper.parseStringMethod(map['description']);
    thumbnailUrl = ParsingHelper.parseStringMethod(map['thumbnailUrl']);
    enabled = ParsingHelper.parseBoolMethod(map['enabled']);
    price = ParsingHelper.parseDoubleMethod(map['price']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "title" : title,
      "description" : description,
      "thumbnailUrl" : thumbnailUrl,
      "enabled" : enabled,
      "price" : price,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}