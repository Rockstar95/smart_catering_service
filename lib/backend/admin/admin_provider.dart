import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_catering_service/models/common/data_model/property_model.dart';
import 'package:smart_catering_service/models/other/data_model/faq_model.dart';

import '../../models/other/data_model/about_model.dart';
import '../common/common_provider.dart';

class AdminProvider extends CommonProvider {
  AdminProvider() {
    propertyModel = CommonProviderPrimitiveParameter<PropertyModel?>(
      value: null,
      notify: notify,
    );
    timeStamp = CommonProviderPrimitiveParameter<Timestamp?>(
      value: null,
      notify: notify,
    );
    aboutModel = CommonProviderPrimitiveParameter<AboutModel>(
      value: AboutModel(),
      notify: notify,
    );
    faqList = CommonProviderListParameter<FAQModel>(
      list: <FAQModel>[],
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<PropertyModel?> propertyModel;
  late CommonProviderPrimitiveParameter<Timestamp?> timeStamp;
  late CommonProviderPrimitiveParameter<AboutModel> aboutModel;
  late CommonProviderListParameter<FAQModel> faqList;

  void reset({bool isNotify = true}) {
    propertyModel.set(value: null, isNotify: false);
    timeStamp.set(value: null, isNotify: false);
    aboutModel.set(value: AboutModel(), isNotify: false);
    faqList.setList(list: [], isClear: true, isNotify: isNotify);
  }
}