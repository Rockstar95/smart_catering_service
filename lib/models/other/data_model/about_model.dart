import 'dart:convert';

class AboutModel {
  String description = "", contact = "", whatsapp = "", facebook = "", googleProfile = "";

  AboutModel({
    this.description = "",
    this.contact = "",
    this.whatsapp = "",
    this.facebook = "",
    this.googleProfile = "",
  });

  AboutModel.fromMap(Map<String, dynamic> map) {
    description = map['description']?.toString() ?? "";
    contact = map['contact']?.toString() ?? "";
    whatsapp = map['whatsapp']?.toString() ?? "";
    facebook = map['facebook']?.toString() ?? "";
    googleProfile = map['googleProfile']?.toString() ?? "";
  }

  Map<String, dynamic> toMap() {
    return {
      "description" : description,
      "contact" : contact,
      "whatsapp" : whatsapp,
      "facebook" : facebook,
      "googleProfile" : googleProfile,
    };
  }

  @override
  String toString() {
    return jsonEncode(toMap());
  }
}