import '../../../utils/my_utils.dart';
import '../../../utils/parsing_helper.dart';

class FAQModel {
  String id = "", question = "", answer = "";
  bool enabled = false;

  FAQModel({
    this.id = "",
    this.question = "",
    this.answer = "",
    this.enabled = false,
  });

  FAQModel.fromMap(Map<String, dynamic> map) {
    id = ParsingHelper.parseStringMethod(map["id"]);
    question = ParsingHelper.parseStringMethod(map["question"]);
    answer = ParsingHelper.parseStringMethod(map["answer"]);
    enabled = ParsingHelper.parseBoolMethod(map["enabled"], defaultValue: true);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      "id" : id,
      "question" : question,
      "answer" : answer,
      "enabled" : enabled,
    };

    return data;
  }

  @override
  String toString() {
    return MyUtils.encodeJson(toMap());
  }
}