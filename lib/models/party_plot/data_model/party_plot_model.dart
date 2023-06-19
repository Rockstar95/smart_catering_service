import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class PartyPlotModel {
  String id = "";
  String title = "";
  String description = "";
  String thumbnailUrl = "";
  String locationArea = "";
  String locationCity = "";
  double minPeople = 0;
  double maxPeople = 0;
  bool enabled = true;
  Timestamp? createdTime;
  Timestamp? updatedTime;
  List<String> photos = <String>[];

  PartyPlotModel({
    this.id = "",
    this.title = "",
    this.description = "",
    this.thumbnailUrl = "",
    this.locationArea = "",
    this.locationCity = "",
    this.minPeople = 0,
    this.maxPeople = 0,
    this.enabled = true,
    this.createdTime,
    this.updatedTime,
    List<String>? photos,
  }) {
    this.photos = photos ?? <String>[];
  }

  PartyPlotModel.fromMap(Map<String, dynamic> map) {
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
    locationArea = ParsingHelper.parseStringMethod(map['locationArea']);
    locationCity = ParsingHelper.parseStringMethod(map['locationCity']);
    minPeople = ParsingHelper.parseDoubleMethod(map['minPeople']);
    maxPeople = ParsingHelper.parseDoubleMethod(map['maxPeople']);
    enabled = ParsingHelper.parseBoolMethod(map['enabled']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);

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
      "locationArea" : locationArea,
      "locationCity" : locationCity,
      "minPeople" : minPeople,
      "maxPeople" : maxPeople,
      "enabled" : enabled,
      "createdTime" : createdTime,
      "updatedTime" : updatedTime,
      "photos" : photos,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}