import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/catering/catering_controller.dart';
import 'package:smart_catering_service/backend/catering/catering_provider.dart';
import 'package:smart_catering_service/models/catering/data_model/catering_model.dart';
import 'package:smart_catering_service/utils/my_safe_state.dart';

import '../../../configs/constants.dart';
import '../../common/components/common_text.dart';
import '../../common/components/loading_widget.dart';
import '../components/catering_card.dart';

class UserCateringListScreen extends StatefulWidget {
  final CateringProvider cateringProvider;

  const UserCateringListScreen({
    Key? key,
    required this.cateringProvider,
  }) : super(key: key);

  @override
  State<UserCateringListScreen> createState() => _UserCateringListScreenState();
}

class _UserCateringListScreenState extends State<UserCateringListScreen> with MySafeState {
  late CateringProvider cateringProvider;
  late CateringController cateringController;

  ScrollController scrollController = ScrollController();

  Future<void> getData({bool isRefresh = true, bool isFromCache = false, bool isNotify = true}) async {
    await cateringController.getCateringsPaginatedList(
      isRefresh: isRefresh,
      isFromCache: isFromCache,
      isNotify: isNotify,
    );
  }

  @override
  void initState() {
    super.initState();

    cateringProvider = widget.cateringProvider;
    cateringController = CateringController(provider: cateringProvider);

    if (cateringProvider.caterings.length == 0 && cateringProvider.hasMoreCaterings.get()) {
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
        ChangeNotifierProvider<CateringProvider>.value(value: cateringProvider),
      ],
      child: Consumer<CateringProvider>(
        builder: (BuildContext context, CateringProvider cateringProvider, Widget? child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Caterings"),
            ),
            body: getProductsListWidget(cateringProvider: cateringProvider),
          );
        },
      ),
    );
  }


  Widget getProductsListWidget({required CateringProvider cateringProvider}) {
    if (cateringProvider.isCateringsFirstTimeLoading.get()) {
      return const LoadingWidget(
        boxSize: 60,
        loaderSize: 40,
      );
    }

    if (!cateringProvider.isCateringsLoading.get() && cateringProvider.caterings.length == 0) {
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
                  child: CommonText(text: "No Caterings Available Currently", fontWeight: FontWeight.bold, fontSize: 17,),
                ),
              ],
            ),
          );
        },
      );
    }

    List<CateringModel> caterings = cateringProvider.caterings.getList(isNewInstance: false);

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
        itemCount: caterings.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if ((index == 0 && caterings.isEmpty) || (index == caterings.length)) {
            if (cateringProvider.isCateringsLoading.get()) {
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

          if (cateringProvider.hasMoreCaterings.get() && index > (caterings.length - AppConstants.cateringsRefreshLimitForPagination)) {
            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              cateringController.getCateringsPaginatedList(isRefresh: false, isFromCache: false, isNotify: false);
            });
          }

          CateringModel model = caterings[index];

          return CateringCard(cateringModel: model);
        },
      ),
    );
  }
}
