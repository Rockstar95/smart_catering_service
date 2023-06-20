import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_catering_service/models/party_plot/data_model/party_plot_model.dart';

import '../../configs/constants.dart';
import '../../configs/typedefs.dart';
import '../../utils/my_print.dart';
import '../../utils/my_utils.dart';
import 'party_plot_provider.dart';
import 'party_plot_repository.dart';

class PartyPlotController {
  late PartyPlotRepository _partyPlotRepository;
  late PartyPlotProvider _partyPlotProvider;

  PartyPlotController({
    required PartyPlotProvider? provider,
    PartyPlotRepository? repository,
  }) {
    _partyPlotRepository = repository ?? PartyPlotRepository();
    _partyPlotProvider = provider ?? PartyPlotProvider();
  }

  PartyPlotRepository get partyPlotRepository => _partyPlotRepository;
  PartyPlotProvider get partyPlotProvider => _partyPlotProvider;

  Future<List<PartyPlotModel>> getPartyPlotsPaginatedList({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    String tag = MyUtils.getNewId();
    MyPrint.printOnConsole("PartyPlotController().getPartyPlotsPaginatedList called with isRefresh:$isRefresh, isFromCache:$isFromCache", tag: tag);

    PartyPlotProvider provider = partyPlotProvider;

    if(!isRefresh && isFromCache && provider.partyPlots.length > 0) {
      MyPrint.printOnConsole("Returning Cached Data", tag: tag);
      return provider.partyPlots.getList(isNewInstance: true);
    }

    if (isRefresh) {
      MyPrint.printOnConsole("Refresh", tag: tag);
      provider.hasMorePartyPlots.set(value: true, isNotify: false); // flag for more products available or not
      provider.lastPartyPlotDocument.set(value: null, isNotify: false); // flag for last document from where next 10 records to be fetched
      provider.isPartyPlotsFirstTimeLoading.set(value: true, isNotify: false);
      provider.isPartyPlotsLoading.set(value: false, isNotify: false);
      provider.partyPlots.setList(list: <PartyPlotModel>[], isNotify: isNotify);
    }

    try {
      if (!provider.hasMorePartyPlots.get()) {
        MyPrint.printOnConsole('No More Courses', tag: tag);
        return provider.partyPlots.getList(isNewInstance: true);
      }
      if (provider.isPartyPlotsLoading.get()) return provider.partyPlots.getList(isNewInstance: true);

      provider.isPartyPlotsLoading.set(value: true, isNotify: isNotify);

      Query<Map<String, dynamic>> query = FirebaseNodes.partyPlotCollectionReference
          .limit(AppConstants.partyPlotsDocumentLimitForPagination)
          .orderBy("createdTime", descending: true);

      //For Last Document
      MyFirestoreDocumentSnapshot? snapshot = provider.lastPartyPlotDocument.get();
      if(snapshot != null) {
        MyPrint.printOnConsole("LastDocument not null", tag: tag);
        query = query.startAfterDocument(snapshot);
      }
      else {
        MyPrint.printOnConsole("LastDocument null", tag: tag);
      }

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      MyPrint.printOnConsole("Documents Length in Firestore for Party Plots:${querySnapshot.docs.length}", tag: tag);

      if (querySnapshot.docs.length < AppConstants.cateringsDocumentLimitForPagination) provider.hasMorePartyPlots.set(value: false, isNotify: false);

      if(querySnapshot.docs.isNotEmpty) provider.lastPartyPlotDocument.set(value: querySnapshot.docs[querySnapshot.docs.length - 1], isNotify: false);

      List<PartyPlotModel> list = [];
      for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
        if((documentSnapshot.data() ?? {}).isNotEmpty) {
          PartyPlotModel cateringModel = PartyPlotModel.fromMap(documentSnapshot.data()!);
          list.add(cateringModel);
        }
      }
      provider.partyPlots.setList(list: list, isClear: false, isNotify: false);
      provider.isPartyPlotsFirstTimeLoading.set(value: false, isNotify: true);
      provider.isPartyPlotsLoading.set(value: false, isNotify: true);
      MyPrint.printOnConsole("Final Party Plots Length From Firestore:${list.length}", tag: tag);
      MyPrint.printOnConsole("Final Party Plots Length in Provider:${provider.partyPlots.length}", tag: tag);
      return list;
    }
    catch(e, s) {
      MyPrint.printOnConsole("Error in PartyPlotController().getPartyPlotsPaginatedList():$e", tag: tag);
      MyPrint.printOnConsole(s, tag: tag);
      provider.reset(isNotify: true);
      return [];
    }
  }
}
