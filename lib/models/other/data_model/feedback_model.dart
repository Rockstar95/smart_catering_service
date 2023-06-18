import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class FeedbackModel {
  String id = "";
  String rating = "";
  String description = "";
  String userId = "";
  String userName = "";
  String mobile = "";
  String type = "";
  Timestamp? createdTime;

  FeedbackModel({
    this.id = "",
    this.rating = "",
    this.description = "",
    this.userId = "",
    this.userName = "",
    this.mobile = "",
    this.type = "",
    this.createdTime,
  });

  FeedbackModel.fromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map["id"]);
    rating = ParsingHelper.parseStringMethod(map["rating"]);
    description = ParsingHelper.parseStringMethod(map["description"]);
    userId = ParsingHelper.parseStringMethod(map["userId"]);
    userName = ParsingHelper.parseStringMethod(map["userName"]);
    mobile = ParsingHelper.parseStringMethod(map["mobile"]);
    type = ParsingHelper.parseStringMethod(map["type"]);
    createdTime = ParsingHelper.parseTimestampMethod(map["createdTime"]);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      "id": id,
      "rating": rating,
      "description": description,
      "userId": userId,
      "userName": userName,
      "mobile": mobile,
      "type": type,
      "createdTime": createdTime,
    };

    return data;
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap());
  }
}