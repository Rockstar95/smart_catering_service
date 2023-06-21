import 'dart:collection';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/models/user/data_model/user_model.dart';
import 'package:smart_catering_service/views/common/components/common_submit_button.dart';

import '../../../backend/authentication/authentication_provider.dart';
import '../../../models/catering/data_model/catering_model.dart';
import '../../../models/catering/data_model/catering_package_model.dart';
import '../../../utils/my_toast.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_text.dart';

class Catering_details extends StatefulWidget {
  final CateringModel cateringModel;

  Catering_details({required this.cateringModel});

  @override
  State<Catering_details> createState() => _Catering_detailsState();
}

class _Catering_detailsState extends State<Catering_details> {
  List<CateringPackageModel> packages = [];
  late AuthenticationProvider authenticationProvider;
  @override
  void initState() {
    super.initState();
    packages = widget.cateringModel.packages;
  }

  @override
  Widget build(BuildContext context) {
    authenticationProvider=Provider.of<AuthenticationProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: _mainBody(),
        appBar: AppBar(

        ),
      ),
    );
  }

  Widget _mainBody() {
    return Column(
      children: [
        SizedBox(height: 20,),
        CarouselSlider.builder(
            itemCount: widget.cateringModel.photos.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) =>
                    CommonCachedNetworkImage(
                      imageUrl: widget.cateringModel.photos[itemIndex],
                      borderRadius: 5,
                    ),
            options: CarouselOptions(
              height: 200,
              aspectRatio: 16 / 9,
              viewportFraction: 0.8,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: Duration(seconds: 2),
              autoPlayAnimationDuration: Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              enlargeFactor: 0.3,
              scrollDirection: Axis.horizontal,
            )),
        Container(
          color: Colors.grey.withOpacity(0.2),
          height: 0.6,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                text: widget.cateringModel.title,
                maxLines: 1,
                fontWeight: FontWeight.bold,
                height: .6,
                fontSize: 21,
              ),
              const SizedBox(height: 8),
              CommonText(
                text: widget.cateringModel.description,
                maxLines: 2,
                textOverFlow: TextOverflow.ellipsis,
                color: const Color(0xff929292),
                fontSize: 12,
              ),
            ],
          ),
        ),
        Expanded(
            child: ListView.builder(
                itemCount: packages.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonCachedNetworkImage(
                          imageUrl: packages[index].thumbnailUrl,
                          borderRadius: 5,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CommonText(
                          text: packages[index].title,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CommonText(
                          text: "Details : ${packages[index].description}",
                          fontSize: 12,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        CommonText(
                            text:
                                "Amount : ${packages[index].price.toString()} / per plate"),
                        SizedBox(
                          height: 5,
                        ),
                        CommonSubmitButton(
                          onTap: () {
                            _showDialog(packages[index]);
                          },
                          text: "Inquiry",
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Container(
                          color: Colors.grey.withOpacity(0.2),
                          height: 0.6,
                        ),
                      ],
                    ),
                  );
                }))
      ],
    );
  }

  _showDialog(CateringPackageModel model) async {
    TextEditingController controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return _SystemPadding(
          child: new AlertDialog(
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    autofocus: true,
                    controller: controller,
                    decoration: new InputDecoration(
                        labelText: 'Enter Person count and customization request', hintText: 'eg. 100, change menu'),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              MaterialButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              MaterialButton(
                  child: const Text('OPEN'),
                  onPressed: () {
                    print("person : ${controller.text}");



                    UserModel? userModel = authenticationProvider.userModel.get();
                    if(userModel!=null) {
                      Map<String, dynamic> data = userModel.toMap();
                      data["plan_name"]=model.title;
                      data["inquiry"]=controller.text;
                      data["cat_id"]=widget.cateringModel.id;
                      data["type"]="cat";

                      FirebaseFirestore.instance.collection("inquiry_cat")
                          .doc()
                          .set(data);
                      MyToast.showSuccess(context: context, msg: "We will call you soon. Thank you .",);
                      Navigator.pop(context);
                    }
                  })
            ],
          ),
        );
      },
    );
  }
}

class _SystemPadding extends StatelessWidget {
  final Widget child;

  _SystemPadding({required this.child});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    return AnimatedContainer(
        padding: mediaQuery.viewInsets,
        duration: const Duration(milliseconds: 300),
        child: child);
  }
}
