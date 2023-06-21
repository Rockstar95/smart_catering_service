import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class Cat_Inuiry {
  String id = "";
  String name = "";
  String imageUrl = "";
  String email = "";
  String mobile = "";
  Timestamp? createdTime;
  Timestamp? updatedTime;
  String inquiry="";
  String cat_id="";
  String plan_name="";
  String type="";

  Cat_Inuiry({
    this.id = "",
    this.name = "",
    this.imageUrl = "",
    this.email = "",
    this.mobile = "",
    this.createdTime,
    this.updatedTime,
    this.inquiry="",
    this.cat_id="",
    this.plan_name="",
    this.type=""
  });

  Cat_Inuiry.fromMap(Map<String, dynamic> map) {
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
    plan_name = ParsingHelper.parseStringMethod(map['plan_name']);
    inquiry = ParsingHelper.parseStringMethod(map['inquiry']);
    cat_id = ParsingHelper.parseStringMethod(map['cat_id']);
    type=ParsingHelper.parseStringMethod(map['type']);

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
