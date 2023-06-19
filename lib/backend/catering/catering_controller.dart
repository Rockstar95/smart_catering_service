import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import 'catering_provider.dart';
import 'catering_repository.dart';

class CateringController {
  late CateringRepository _cateringRepository;
  late CateringProvider _cateringProvider;

  CateringController({
    required CateringProvider? provider,
    CateringRepository? repository,
  }) {
    _cateringRepository = repository ?? CateringRepository();
    _cateringProvider = provider ?? CateringProvider();
  }

  CateringRepository get cateringRepository => _cateringRepository;
  CateringProvider get cateringProvider => _cateringProvider;

  Future<List<CateringModel>> getCateringsPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("CourseController().getCateringsPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    CateringProvider provider = cateringProvider;

    if(!isRefresh && isFromCache && provider.caterings.length > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.caterings.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMoreCaterings.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastCateringDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isCateringsFirstTimeLoading.set(value: true, isNotify: false);
      provider.isCateringsLoading.set(value: false, isNotify: false);
      provider.caterings.setList(list: <CateringModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMoreCaterings.get()) {
        MyPrint.printOnConsole('No More Courses', tag: tag);
        return provider.caterings.getList(isNewInstance: true);
      }
      if (provider.isCateringsLoading.get()) return provider.caterings.getList(isNewInstance: true);

      provider.isCateringsLoading.set(value: true, isNotify: isNotify);

      Query<Map<String, dynamic>> query = FirebaseNodes.cateringCollectionReference
          .limit(AppConstants.cateringsDocumentLimitForPagination)
          .orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastCateringDocument.get();
      if(snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      }
      else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Caterings:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.cateringsDocumentLimitForPagination) provider.hasMoreCaterings.set(value: false, isNotify: false);

      if(querySnapshot.docs.isNotEmpty) provider.lastCateringDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<CateringModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          CateringModel cateringModel = CateringModel.fromMap(documentSnapshot.data()!);
          list.add(cateringModel);
        }
      }
      provider.caterings.setList(list: list, isClear: false, isNotify: false);
      provider.isCateringsFirstTimeLoading.set(value: false, isNotify: true);
      provider.isCateringsLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Caterings Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Caterings Length in Provider:${provider.caterings.length}", tag: tag);
      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in CourseController().getCateringsPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.reset(isNotify: true);
      return [];
    }
  }
}
