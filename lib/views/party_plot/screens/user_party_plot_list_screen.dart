import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/party_plot/party_plot_controller.dart';
import 'package:smart_catering_service/backend/party_plot/party_plot_provider.dart';
import 'package:smart_catering_service/models/party_plot/data_model/party_plot_model.dart';
import 'package:smart_catering_service/utils/my_safe_state.dart';

import '../../../configs/constants.dart';
import '../../common/components/common_text.dart';
import '../../common/components/loading_widget.dart';
import '../components/party_plot_card.dart';

class UserPartyPlotListScreen extends StatefulWidget {
  final PartyPlotProvider partyPlotProvider;

  const UserPartyPlotListScreen({
    Key? key,
    required this.partyPlotProvider,
  }) : super(key: key);

  @override
  State<UserPartyPlotListScreen> createState() => _UserPartyPlotListScreenState();
}

class _UserPartyPlotListScreenState extends State<UserPartyPlotListScreen> with MySafeState {
  late PartyPlotProvider partyPlotProvider;
  late PartyPlotController partyPlotController;

  ScrollController scrollController = ScrollController();

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await partyPlotController.getPartyPlotsPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();

    partyPlotProvider = widget.partyPlotProvider;
    partyPlotController = PartyPlotController(provider: partyPlotProvider);

    if (partyPlotProvider.partyPlots.length == 0 && partyPlotProvider.hasMorePartyPlots.get()) {
      getData(
        isRefresh: true,
        isFromCache: false,
        isNotify: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.pageBuild();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PartyPlotProvider>.value(value: partyPlotProvider),
      ],
      child: Consumer<PartyPlotProvider>(
        builder: (BuildContext context, PartyPlotProvider partyPlotProvider, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Party Plots"),
            ),
            body: getProductsListWidget(partyPlotProvider: partyPlotProvider),
          );
        },
      ),
    );
  }


  Widget getProductsListWidget({required PartyPlotProvider partyPlotProvider}) {
    if (partyPlotProvider.isPartyPlotsFirstTimeLoading.get()) {
      return const LoadingWidget(
        boxSize: 60,
        loaderSize: 40,
      );
    }

    if (!partyPlotProvider.isPartyPlotsLoading.get() && partyPlotProvider.partyPlots.length == 0) {
      return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return RefreshIndicator(
            onRefresh: () async {
              await getData(
                isRefresh: true,
                isFromCache: false,
                isNotify: true,
              );
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
              children: [
                SizedBox(height: constraints.maxHeight / 2.05),
                const Center(
                  child: CommonText(text: "No Party Plots Available Currently", fontWeight: FontWeight.bold, fontSize: 17,),
                ),
              ],
            ),
          );
        },
      );
    }

    List<PartyPlotModel> partyPlots = partyPlotProvider.partyPlots.getList(isNewInstance: false);

    double? cacheExtent = scrollController.hasClients ? scrollController.position.maxScrollExtent : null;
    // MyPrint.printOnConsole("cacheExtent:$cacheExtent");

    return RefreshIndicator(
      onRefresh: () async {
        await getData(
          isRefresh: true,
          isFromCache: false,
          isNotify: true,
        );
      },
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        cacheExtent: cacheExtent,
        itemCount: partyPlots.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if ((index == 0 && partyPlots.isEmpty) || (index == partyPlots.length)) {
            if (partyPlotProvider.isPartyPlotsLoading.get()) {
              // if(true) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: LoadingAnimationWidget.threeArchedCircle(
                      color: themeData.primaryColor,
                      size: 40,
                    ),
                  ),
                ],
              );
            } else {
              return const SizedBox();
            }
          }

          if (partyPlotProvider.hasMorePartyPlots.get() && index > (partyPlots.length - AppConstants.partyPlotsRefreshLimitForPagination)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              partyPlotController.getPartyPlotsPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
            });
          }

          PartyPlotModel model = partyPlots[index];

          return PartyPlotCard(partyPlotModel: model);
        },
      ),
    );
  }
}
