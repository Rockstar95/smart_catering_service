import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

import '../../../backend/authentication/authentication_provider.dart';
import '../../../backend/common/firestore_controller.dart';
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
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => InquiryAddPage(

                    plan_name:"",
                    type: "plot",
                    cat_id: widget.partyPlotModel.id,
                  ),
                ));
           // _showDialog();
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



class InquiryAddPage extends StatefulWidget {

  final String plan_name;
  final String cat_id;
  final String type;

  const InquiryAddPage(
      {
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
  String totalperson = "0";
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
      data["bookingamount"] = "";
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
          .where("cat_id", isEqualTo: widget.cat_id).where("type",isEqualTo: "plot")
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
                        totalperson=personinput.text;
                        setState(() {

                        });
                      },
                      decoration:
                      InputDecoration(hintText: "Enter no of person"),
                    ),
                    Text("Some details :"),
                    TextField(
                      controller: inquiryInput,
                      onChanged: (val) {

                      },
                      decoration: InputDecoration(hintText: "Enter any Query"),
                    ),

                    Visibility(
                      visible: totalperson != "0" && showDate && showTime,
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
