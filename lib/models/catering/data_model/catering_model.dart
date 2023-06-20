import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';
import 'catering_package_model.dart';

class CateringModel {
  String id = "";
  String title = "";
  String description = "";
  String thumbnailUrl = "";
  bool enabled = true;
  Timestamp? createdTime;
  Timestamp? updatedTime;
  List<CateringPackageModel> packages = <CateringPackageModel>[];
  List<String> photos = <String>[];

  CateringModel({
    this.id = "",
    this.title = "",
    this.description = "",
    this.thumbnailUrl = "",
    this.enabled = true,
    this.createdTime,
    this.updatedTime,
    List<CateringPackageModel>? packages,
    List<String>? photos,
  }) {
    this.packages = packages ?? <CateringPackageModel>[];
    this.photos = photos ?? <String>[];
  }

  CateringModel.fromMap(Map<String, dynamic> map) {
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
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);

    packages.clear();
    List<Map<String, dynamic>> packagesMapsList = ParsingHelper.parseMapsListMethod<String, dynamic>(map['packages']);
    packages.addAll(packagesMapsList.map((e) {
      return CateringPackageModel.fromMap(e);
    }).toList());

    photos.clear();
    List<String> photosList = ParsingHelper.parseListMethod<dynamic, String>(map['photos']);
    photos.addAll(photosList);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id" : id,
      "title" : title,
      "description" : description,
      "thumbnailUrl" : thumbnailUrl,
      "enabled" : enabled,
      "createdTime" : toJson ? createdTime?.millisecondsSinceEpoch : createdTime,
      "updatedTime" : toJson ? updatedTime?.millisecondsSinceEpoch : updatedTime,
      "packages" : packages.map((e) => e.toMap(toJson: toJson)).toList(),
      "photos" : photos,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}