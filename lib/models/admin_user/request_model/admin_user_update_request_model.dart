import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/my_utils.dart';

class AdminUserUpdateRequestModel {
  String id = "";
  bool? isProfileSet;
  bool? isCateringEnabled;
  bool? isPartyPlotEnabled;
  Timestamp? updatedTime;

  AdminUserUpdateRequestModel({
    required this.id,
    this.isProfileSet,
    this.isCateringEnabled,
    this.isPartyPlotEnabled,
    this.updatedTime,
  });

  Map<String, dynamic> toMap({bool toJson = false}) {
    return <String, dynamic>{
      if(isProfileSet != null) "isProfileSet" : isProfileSet,
      if(isCateringEnabled != null) "isCateringEnabled" : isCateringEnabled,
      if(isPartyPlotEnabled != null) "isPartyPlotEnabled" : isPartyPlotEnabled,
      if(updatedTime != null) "updatedTime" : toJson ? updatedTime?.toDate().millisecondsSinceEpoch : updatedTime,
    };
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap(toJson: true));
  }
}