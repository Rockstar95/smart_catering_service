import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';

import '../../configs/typedefs.dart';
import '../common/common_provider.dart';

class CateringProvider extends CommonProvider {
  CateringProvider() {
    caterings = CommonProviderListParameter<CateringModel>(
      list: [],
      notify: notify,
    );
    lastCateringDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMoreCaterings = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isCateringsFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isCateringsLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
  }

  //region Courses Paginated List
  late CommonProviderListParameter<CateringModel> caterings;
  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastCateringDocument;
  late CommonProviderPrimitiveParameter<bool> hasMoreCaterings;
  late CommonProviderPrimitiveParameter<bool> isCateringsFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isCateringsLoading;
  //endregion

  void reset({bool isNotify = true}) {
    caterings.setList(list: [], isNotify: false);
    lastCateringDocument.set(value: null, isNotify: false);
    hasMoreCaterings.set(value: true, isNotify: false);
    isCateringsFirstTimeLoading.set(value: false, isNotify: false);
    isCateringsLoading.set(value: false, isNotify: false);
  }
}