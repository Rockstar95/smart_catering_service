import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/models/inquiry/cat_inquiry.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../backend/authentication/authentication_provider.dart';
import '../../../models/admin_user/data_model/admin_user_model.dart';
import '../../common/components/common_text.dart';

class CateringInquiryScreen extends StatefulWidget {
  const CateringInquiryScreen({Key? key}) : super(key: key);

  @override
  State<CateringInquiryScreen> createState() => _CateringInquiryScreenState();
}

class _CateringInquiryScreenState extends State<CateringInquiryScreen> {
  late AuthenticationProvider authenticationProvider;
  AdminUserModel? adminUserModel;
  List<Cat_Inuiry> list = [];
  void getData() async {
    adminUserModel = authenticationProvider.adminUserModel.get();
    if (adminUserModel != null) {
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection("inquiry_cat")
          .where("cat_id", isEqualTo: adminUserModel!.id)
          .where("type", isEqualTo: "cat");

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await query.get();
      print("data : ${querySnapshot.size}");
      for (DocumentSnapshot<Map<String, dynamic>> documentSnapshot
          in querySnapshot.docs) {
        if ((documentSnapshot.data() ?? {}).isNotEmpty) {
          Cat_Inuiry cateringModel =
              Cat_Inuiry.fromMap(documentSnapshot.data()!);
          list.add(cateringModel);
        }
      }
      setState(() {

      });
      print("data : ${list.length}");
    }
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 400), () {
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    authenticationProvider = Provider.of<AuthenticationProvider>(context);
    return SafeArea(child: _mainBody());
  }

  Widget _mainBody() {
    return list.isEmpty?Container(child: Center(child: Text("No Inquiry Found")),):
    Column(
      children: [
        Expanded(child: ListView.builder(
            itemCount: list.length,
            itemBuilder: (ctx, index) {

          return inquiryItem(list[index]);

        }))
      ],
    );
  }

  Widget inquiryItem(Cat_Inuiry model)
  {
   return GestureDetector(
      onTap: () {
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              blurRadius: 25,
              offset: const Offset(0, 0),
              spreadRadius: 0,
              color: Colors.black.withOpacity(0.12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              color: Colors.grey.withOpacity(0.2),
              height: 0.6,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CommonText(
                        text: model.name,
                        maxLines: 1,
                        fontWeight: FontWeight.bold,
                        height: .6,
                        fontSize: 21,
                      ),
                      Spacer(),
                      InkWell(child: Icon(Icons.phone),
                      onTap: ()async{
                        if (!await launchUrl(Uri.parse("tel://${model.mobile}"))) {
                        }
                      },)
                    ],
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    text: "Mobile :  ${model.mobile}",
                    maxLines: 2,
                    textOverFlow: TextOverflow.ellipsis,

                    fontSize: 12,
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    text:"Email :  ${model.email}",
                    maxLines: 2,
                    textOverFlow: TextOverflow.ellipsis,

                    fontSize: 12,
                  ),
                  Container(
                    color: Colors.black,
                    margin: EdgeInsets.all(5),
                    height: 0.6,
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    text:"Menu name :  ${model.plan_name}",
                    maxLines: 2,
                    textOverFlow: TextOverflow.ellipsis,

                    fontSize: 12,
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    text:"Inquiry Description :  ${model.inquiry}",
                    maxLines: 2,
                    textOverFlow: TextOverflow.ellipsis,

                    fontSize: 12,
                  ),
                  Container(
                    color: Colors.black,
                    margin: EdgeInsets.all(5),
                    height: 0.6,
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    text:"Bookingd date :  ${model.bookingdate}",
                    maxLines: 2,
                    textOverFlow: TextOverflow.ellipsis,

                    fontSize: 12,
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    text:"Booking time :  ${model.bookingtime}",
                    maxLines: 2,
                    textOverFlow: TextOverflow.ellipsis,

                    fontSize: 12,
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    text:"Person :  ${model.bookingperson}",
                    maxLines: 2,
                    textOverFlow: TextOverflow.ellipsis,

                    fontSize: 12,
                  ),
                  const SizedBox(height: 8),
                  CommonText(
                    text:"Total Amount :  ${model.bookingamount}",
                    maxLines: 2,
                    textOverFlow: TextOverflow.ellipsis,

                    fontSize: 12,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


}
