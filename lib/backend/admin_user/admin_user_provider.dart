import 'package:smart_catering_service/backend/common/common_provider.dart';
import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';
import 'package:smart_catering_service/models/party_plot/data_model/party_plot_model.dart';

class AdminUserProvider extends CommonProvider {
  AdminUserProvider() {
    cateringModel = CommonProviderPrimitiveParameter<CateringModel>(
      value: CateringModel(),
      newInstancialization: (CateringModel cateringModel) {
        return CateringModel.fromMap(cateringModel.toMap());
      },
      notify: notify,
    );
    partyPlotModel = CommonProviderPrimitiveParameter<PartyPlotModel>(
      value: PartyPlotModel(),
      newInstancialization: (PartyPlotModel partyPlotModel) {
        return PartyPlotModel.fromMap(partyPlotModel.toMap());
      },
      notify: notify,
    );
  }

  late CommonProviderPrimitiveParameter<CateringModel> cateringModel;
  late CommonProviderPrimitiveParameter<PartyPlotModel> partyPlotModel;

  void reset({bool isNotify = true}) {
    cateringModel.set(value: CateringModel(), isNewInstance: true, isNotify: false);
    partyPlotModel.set(value: PartyPlotModel(), isNewInstance: true, isNotify: isNotify);
  }
}