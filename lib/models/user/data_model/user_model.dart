import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class UserModel {
  String id = "";
  String name = "";
  String imageUrl = "";
  String email = "";
  String mobile = "";
  Timestamp? createdTime;
  Timestamp? updatedTime;

  UserModel({
    this.id = "",
    this.name = "",
    this.imageUrl = "",
    this.email = "",
    this.mobile = "",
    this.createdTime,
    this.updatedTime,
  });

  UserModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    name = ParsingHelper.parseStringMethod(map['name']);
    imageUrl = ParsingHelper.parseStringMethod(map['imageUrl']);
    email = ParsingHelper.parseStringMethod(map['email']);
    mobile = ParsingHelper.parseStringMethod(map['mobile']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "name": name,
      "imageUrl": imageUrl,
      "email": email,
      "mobile": mobile,
      "createdTime": toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime": toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
