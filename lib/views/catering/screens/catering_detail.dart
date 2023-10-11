import 'dart:collection';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_catering_service/backend/common/firestore_controller.dart';
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
    authenticationProvider = Provider.of<AuthenticationProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: _mainBody(),
        appBar: AppBar(),
      ),
    );
  }

  Widget _mainBody() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
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
                            //  _showDialog(packages[index]);

                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => InquiryAddPage(
                                    model: packages[index],
                                    plan_name: packages[index].title,
                                    type: "cat",
                                    cat_id: widget.cateringModel.id,
                                  ),
                                ));
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
                        labelText:
                            'Enter Person count and customization request',
                        hintText: 'eg. 100, change menu'),
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

                    UserModel? userModel =
                        authenticationProvider.userModel.get();
                    if (userModel != null) {
                      Map<String, dynamic> data = userModel.toMap();
                      data["plan_name"] = model.title;
                      data["inquiry"] = controller.text;
                      data["cat_id"] = widget.cateringModel.id;
                      data["type"] = "cat";

                      FirebaseFirestore.instance
                          .collection("inquiry_cat")
                          .doc()
                          .set(data);
                      MyToast.showSuccess(
                        context: context,
                        msg: "We will call you soon. Thank you .",
                      );
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

class InquiryAddPage extends StatefulWidget {
  final CateringPackageModel model;
  final String plan_name;
  final String cat_id;
  final String type;

  const InquiryAddPage(
      {required this.model,
      required this.cat_id,
      required this.plan_name,
      required this.type});

  @override
  State<InquiryAddPage> createState() => _InquiryAddPageState();
}

class _InquiryAddPageState extends State<InquiryAddPage> {
  late AuthenticationProvider authenticationProvider;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime dateTime = DateTime.now();
  bool showDate = false;
  bool showTime = false;
  bool showDateTime = false;

  TextEditingController personinput = TextEditingController();
  TextEditingController inquiryInput = TextEditingController();
  String totalAmount = "0";
  bool isValid = true;

  void sendBooking() {
    UserModel? userModel = authenticationProvider.userModel.get();
    if (userModel != null) {
      Map<String, dynamic> data = userModel.toMap();
      data["plan_name"] = widget.plan_name;
      data["inquiry"] = inquiryInput.text;
      data["cat_id"] = widget.cat_id;
      data["type"] = widget.type;
      data["bookingdate"] =
          DateFormat('MMM d, yyyy').format(selectedDate).toString();
      data["bookingamount"] = totalAmount;
      data["bookingperson"] = personinput.text;
      data["bookingtime"] = getTime(selectedTime);
      FirebaseFirestore.instance.collection("inquiry_cat").doc().set(data);
      MyToast.showSuccess(
        context: context,
        msg:
            "Your booking is successfully done. We will call you soon. Thank you .",
      );
      Navigator.pop(context);
    }
  }

  void setTotalAmount() {
    String person = personinput.text;
    try {
      double value = int.parse(person) * widget.model.price;
      totalAmount = "$value";
      setState(() {});
    } catch (e) {
      totalAmount = "0";
      setState(() {});
    }
  }

  // Select for Date
  Future<DateTime> _selectDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (selected != null && selected != selectedDate) {
      setState(() {
        selectedDate = selected;
      });

      await FirestoreController.firestore
          .collection("inquiry_cat")
          .where("bookingdate",
              isEqualTo:
                  DateFormat('MMM d, yyyy').format(selectedDate).toString())
          .where("cat_id", isEqualTo: widget.cat_id).where("type",isEqualTo: "cat")
          .get()
          .then((value) {
        isValid = value.docs.length == 0;

        setState(() {});
      });
    }
    return selectedDate;
  }

// Select for Time
  Future<TimeOfDay> _selectTime(BuildContext context) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (selected != null && selected != selectedTime) {
      setState(() {
        selectedTime = selected;
      });
    }
    return selectedTime;
  }

  // select date time picker

  Future _selectDateTime(BuildContext context) async {
    final date = await _selectDate(context);
    if (date == null) return;

    final time = await _selectTime(context);

    if (time == null) return;
    setState(() async {
      dateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String getDate() {
    // ignore: unnecessary_null_comparison
    if (selectedDate == null) {
      return 'select date';
    } else {
      return DateFormat('MMM d, yyyy').format(selectedDate);
    }
  }

  String getDateTime() {
    // ignore: unnecessary_null_comparison
    if (dateTime == null) {
      return 'select date timer';
    } else {
      return DateFormat('yyyy-MM-dd HH: ss a').format(dateTime);
    }
  }

  String getTime(TimeOfDay tod) {
    final now = DateTime.now();

    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm();
    return format.format(dt);
  }

  @override
  Widget build(BuildContext context) {
    authenticationProvider = Provider.of<AuthenticationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Add Booking"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Select date and time : "),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _selectDate(context);
                    showDate = true;
                  },
                  child: const Text('Select Date'),
                ),
              ),
              showDate ? Center(child: Text(getDate())) : const SizedBox(),

              Visibility(
                visible: isValid,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _selectTime(context);
                          showTime = true;
                        },
                        child: const Text('Select Time'),
                      ),
                    ),
                    showTime
                        ? Center(child: Text(getTime(selectedTime)))
                        : const SizedBox(),
                    Text("Enter number of person :"),
                    TextField(
                      controller: personinput,
                      onChanged: (val) {
                        setTotalAmount();
                      },
                      decoration:
                          InputDecoration(hintText: "Enter no of person"),
                    ),
                    Text("Some details :"),
                    TextField(
                      controller: inquiryInput,
                      onChanged: (val) {
                        setTotalAmount();
                      },
                      decoration: InputDecoration(hintText: "Enter any Query"),
                    ),
                    Text(
                      "Total Rs : $totalAmount",
                      style: TextStyle(fontSize: 20),
                    ),
                    Visibility(
                      visible: totalAmount != "0" && showDate && showTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 100),
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            sendBooking();
                          },
                          child: const Text('Book'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Visibility(
                visible: !isValid,
                child: Text(
                  "This date is already booked. please select another date",
                  style: TextStyle(fontSize: 20),
                ),
              )
            ],
          ),
        ),
      ),
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
