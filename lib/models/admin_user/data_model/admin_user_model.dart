import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class AdminUserModel {
  String id = "";
  String email = "";
  bool isCateringEnabled = false;
  bool isPartyPlotEnabled = false;
  Timestamp? createdTime;
  Timestamp? updatedTime;

  AdminUserModel({
    this.id = "",
    this.email = "",
    this.isCateringEnabled = false,
    this.isPartyPlotEnabled = false,
    this.createdTime,
    this.updatedTime,
  });

  AdminUserModel.fromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void updateFromMap(Map<String, dynamic> map) {
    initializeFromMap(map);
  }

  void initializeFromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map['id']);
    email = ParsingHelper.parseStringMethod(map['email']);
    isCateringEnabled = ParsingHelper.parseBoolMethod(map['isCateringEnabled']);
    isPartyPlotEnabled = ParsingHelper.parseBoolMethod(map['isPartyPlotEnabled']);
    createdTime = ParsingHelper.parseTimestampMethod(map['createdTime']);
    updatedTime = ParsingHelper.parseTimestampMethod(map['updatedTime']);
  }

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      "id": id,
      "email": email,
      "isCateringEnabled": isCateringEnabled,
      "isPartyPlotEnabled": isPartyPlotEnabled,
      "createdTime": toJson ? createdTime?.toDate().millisecondsSinceEpoch : createdTime,
      "updatedTime": toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}
