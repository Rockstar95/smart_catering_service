import 'package:smart_catering_service/models/party_plot/data_model/party_plot_model.dart';

import '../../configs/typedefs.dart';
import '../common/common_provider.dart';

class PartyPlotProvider extends CommonProvider {
  PartyPlotProvider() {
    partyPlots = CommonProviderListParameter<PartyPlotModel>(
      list: [],
      notify: notify,
    );
    lastPartyPlotDocument = CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?>(
      value: null,
      notify: notify,
    );
    hasMorePartyPlots = CommonProviderPrimitiveParameter<bool>(
      value: true,
      notify: notify,
    );
    isPartyPlotsFirstTimeLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
    isPartyPlotsLoading = CommonProviderPrimitiveParameter<bool>(
      value: false,
      notify: notify,
    );
  }

  //region Courses Paginated List
  late CommonProviderListParameter<PartyPlotModel> partyPlots;
  late CommonProviderPrimitiveParameter<MyFirestoreQueryDocumentSnapshot?> lastPartyPlotDocument;
  late CommonProviderPrimitiveParameter<bool> hasMorePartyPlots;
  late CommonProviderPrimitiveParameter<bool> isPartyPlotsFirstTimeLoading;
  late CommonProviderPrimitiveParameter<bool> isPartyPlotsLoading;
  //endregion

  void reset({bool isNotify = true}) {
    partyPlots.setList(list: [], isNotify: false);
    lastPartyPlotDocument.set(value: null, isNotify: false);
    hasMorePartyPlots.set(value: true, isNotify: false);
    isPartyPlotsFirstTimeLoading.set(value: false, isNotify: false);
    isPartyPlotsLoading.set(value: false, isNotify: false);
  }
}