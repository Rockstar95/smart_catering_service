import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/authentication_provider.dart';
import '../../../models/catering/data_model/catering_package_model.dart';
import '../../../models/party_plot/data_model/party_plot_model.dart';
import '../../../models/user/data_model/user_model.dart';
import '../../../utils/my_toast.dart';
import '../../common/components/common_cachednetwork_image.dart';
import '../../common/components/common_submit_button.dart';
import '../../common/components/common_text.dart';

class PartyPlotDetail extends StatefulWidget {
  final PartyPlotModel partyPlotModel;
  PartyPlotDetail({required this.partyPlotModel});

  @override
  State<PartyPlotDetail> createState() => _PartyPlotDetailState();
}

class _PartyPlotDetailState extends State<PartyPlotDetail> {

  late AuthenticationProvider authenticationProvider;
  @override
  void initState() {
    super.initState();
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

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                text: widget.partyPlotModel.title,
                maxLines: 1,
                fontWeight: FontWeight.bold,
                height: .6,
                fontSize: 21,
              ),
              const SizedBox(height: 8),
              CommonText(
                text: widget.partyPlotModel.description,
                maxLines: 2,
                textOverFlow: TextOverflow.ellipsis,
                color: const Color(0xff929292),
                fontSize: 12,
              ),
            ],
          ),
        ),
        SizedBox(height: 20,),
        CarouselSlider.builder(
            itemCount: widget.partyPlotModel.photos.length,
            itemBuilder:
                (BuildContext context, int itemIndex, int pageViewIndex) =>
                CommonCachedNetworkImage(
                  imageUrl: widget.partyPlotModel.photos[itemIndex],
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

        SizedBox(height: 20,),
        Container(
          color: Colors.grey.withOpacity(0.2),
          height: 0.6,
        ),
        Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                text: "People Size ${widget.partyPlotModel.minPeople.toInt()} - ${widget.partyPlotModel.maxPeople.toInt()}",
                maxLines: 1,
                fontWeight: FontWeight.bold,
                height: .6,
                fontSize: 21,
              ),
              const SizedBox(height: 8),
              CommonText(
                text: "City  : ${widget.partyPlotModel.locationCity}",
                maxLines: 2,
                textOverFlow: TextOverflow.ellipsis,
                color: const Color(0xff929292),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              const SizedBox(height: 8),
              CommonText(
                text:  "Area  : ${widget.partyPlotModel.locationArea}",
                maxLines: 2,
                textOverFlow: TextOverflow.ellipsis,
                color: const Color(0xff929292),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
        CommonSubmitButton(
          onTap: () {
            _showDialog();
          },
          text: "Inquiry",
        ),
      ],
    );
  }

  _showDialog() async {
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
                    maxLines: 3,
                    minLines: 3,
                    decoration: new InputDecoration(
                        labelText: 'Enter Person count and date ', hintText: 'eg. 100, 21/03/2023'),
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
                      data["plan_name"]="";
                      data["inquiry"]=controller.text;
                      data["cat_id"]=widget.partyPlotModel.id;
                      data["type"]="plot";

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
