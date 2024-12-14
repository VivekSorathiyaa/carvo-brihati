// ignore_for_file: non_constant_identifier_names, prefer_typing_uninitialized_variables, empty_catches, avoid_print
import 'dart:convert';
import 'dart:developer';

import 'package:carlink/model/booknow_modal.dart';
import 'package:carlink/model/coupanlist_modal.dart';
import 'package:carlink/model/couponcheck_modal.dart';
import 'package:carlink/model/pgatway_modal.dart';
import 'package:carlink/model/walletreport_modal.dart';
import 'package:carlink/payments/mercadopago.dart';
import 'package:carlink/payments/midtrans.dart';
import 'package:carlink/payments/razorpay_screen.dart';
import 'package:carlink/screen/detailcar/successful_screen.dart';
import 'package:carlink/screen/login_flow/login_screen.dart';
import 'package:carlink/screen/login_flow/signup_screen.dart';
import 'package:carlink/screen/verification_screens/verification_screen.dart';
import 'package:carlink/utils/common.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:carlink/utils/config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:readmore/readmore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../payments/flutterwave.dart';
import '../../payments/inputformater.dart';
import '../../payments/khalti.dart';
import '../../payments/payfast.dart';
import '../../payments/paymentcard.dart';
import '../../payments/paypalPayment.dart';
import '../../payments/paystack.dart';
import '../../payments/paytmpayment.dart';
import '../../payments/senangpay.dart';
import '../../payments/stripe_payment.dart';
import '../../utils/App_content.dart';
import '../../utils/Colors.dart';
import '../../utils/Custom_widget.dart';
import '../../utils/Dark_lightmode.dart';
import '../../utils/fontfameli_model.dart';
import 'package:intl/intl.dart';

class ReviewSummery extends StatefulWidget {
  final String Picktime;
  final String returnTime;
  final bool toggle;
  final String startDate;
  final String endDate;
  final String hours;
  final String days;
  final String sTime;
  final String eTime;
  const ReviewSummery(
      {super.key,
      required this.Picktime,
      required this.returnTime,
      required this.toggle,
      required this.startDate,
      required this.endDate,
      required this.hours,
      required this.days,
      required this.sTime,
      required this.eTime});

  @override
  State<ReviewSummery> createState() => _ReviewSummeryState();
}

class _ReviewSummeryState extends State<ReviewSummery> {
  bool light = false;
  bool Loading = true;
  bool isVerified = false;

  var coupon = 0;

  late ColorNotifire notifire;

  int payment = 0;
  int inDex = 0;
  var cAmt;
  var total;

  @override
  void initState() {
    Payment();
    cData();
    getvalidate();
    print("**********");
    print("pickup time ${widget.Picktime}");
    print(" start date${widget.startDate}");
    print("end date ${widget.endDate}");
    print("end time${widget.eTime}");
    print("**********");
    razorPayClass.initiateRazorPay(
        handlePaymentSuccess: handlePaymentSuccess,
        handlePaymentError: handlePaymentError,
        handleExternalWallet: handleExternalWallet);
    super.initState();
  }

  void showGuestUserPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Guest User",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black),
          ),
          content: Text(
            textAlign: TextAlign.center,
            "You are currently signed in as a guest. Sign up or log in to enjoy more features!",
            style: TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    SizedBox(width: 50),
                    ElevatedButton(
                      child: Text("Sign Up"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.to(SignUpScreen());
                      },
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    ElevatedButton(
                      child: Text("Log In"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Get.to(LoginScreen());
                      },
                    ),
                  ],
                ),
                TextButton(
                  child: Text("Continue as Guest"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> getStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isVerified = prefs.getBool("isVerified") ?? false;
    print(isVerified);
  }

  late BookNowModal bookNow;
  Future bNow(
      carId,
      uId,
      carPrice,
      pType,
      pDate,
      pTime,
      rDate,
      rTime,
      couponId,
      couponAmt,
      wallAnt,
      totalDay,
      subtotal,
      tax,
      tAmt,
      tfinal,
      pMethod,
      paymentId,
      typeId,
      brandId,
      bookType,
      cityId) async {
    if (isLoads) {
      return;
    } else {
      isLoads = true;
    }
    Map body = {
      "car_id": carId,
      "uid": uId,
      "car_price": carPrice,
      "price_type": pType,
      "pickup_date": pDate,
      "pickup_time": pTime,
      "return_date": rDate,
      "return_time": rTime,
      "cou_id": couponId,
      "cou_amt": couponAmt,
      "wall_amt": wallAnt,
      "total_day_or_hr": totalDay,
      "subtotal": subtotal,
      "tax_per": tax,
      "tax_amt": tAmt,
      "o_total": tfinal,
      "p_method_id": pMethod,
      "transaction_id": paymentId,
      "type_id": typeId,
      "brand_id": brandId,
      "book_type": bookType,
      "city_id": cityId,
    };

    print(body);
    log("**************");

    try {
      var response = await http.post(Uri.parse(Config.baseUrl + Config.bookNow),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });
      print('+--++-+-+-${response.body}');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        var book = bookNowModalFromJson(response.body);
        setState(() {
          isLoads = false;
          if (book.result == "true") {
            Get.offAll(const SuccessfulScreen());
            Fluttertoast.showToast(msg: book.responseMsg);
          } else {
            Fluttertoast.showToast(msg: book.responseMsg);
          }
        });
        return data;
      } else {
        print("booking not successful");
      }
    } catch (e) {
      print(e);
    }
  }

  RazorPayClass razorPayClass = RazorPayClass();

  void handlePaymentSuccess(PaymentSuccessResponse response) {
    bNow(
        car['id'],
        id['id'],
        widget.toggle == true
            ? car['car_rent_price_driver']
            : car['car_rent_price'],
        car['price_type'] == '1' ? 'hr' : 'days',
        widget.startDate,
        widget.sTime,
        widget.endDate,
        widget.eTime,
        coupon == 1 ? cList?.couponlist[inDex].id : '0',
        cAmt ?? '0',
        walletValue,
        car['price_type'] == '1' ? widget.hours : widget.days,
        total.toStringAsFixed(2),
        tax['tax'],
        totalTax,
        totalPayment.toStringAsFixed(2),
        gPayment?.paymentdata[0].id,
        response.paymentId,
        car['type_id'],
        car['brand_id'],
        widget.toggle == true ? 'With' : 'Without',
        car['city_id']);
    Fluttertoast.showToast(
        msg: 'SUCCESS PAYMENT : ${response.paymentId}', timeInSecForIosWeb: 4);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: 'ERROR HERE: ${response.code} - ${response.message}',
        timeInSecForIosWeb: 4);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: 'EXTERNAL_WALLET IS: ${response.walletName}',
        timeInSecForIosWeb: 4);
  }

  @override
  void dispose() {
    razorPayClass.desposRazorPay();
    super.dispose();
  }

  late String finalId;
  PGateway? gPayment;
  Couponlist? cList;
  CouponCheck? cCoupon;
  // Payment Api
  Future Payment() async {
    try {
      var response =
          await http.post(Uri.parse(Config.baseUrl + Config.payment), headers: {
        'Content-Type': 'application/json',
      });
      print("*********");
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          gPayment = pGatewayFromJson(response.body);
          Loading = false;
        });
      } else {}
    } catch (e) {}
  }

  //  Coupon Api
  Future Coupon(uid) async {
    Map body = {
      "uid": uid,
    };
    try {
      var response = await http.post(Uri.parse(Config.baseUrl + Config.coupon),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });
      if (response.statusCode == 200) {
        setState(() {
          cList = couponlistFromJson(response.body);
          Loading = false;
        });
      } else {}
    } catch (e) {}
  }

  //  Coupon Check Api
  Future Check(uid, cid) async {
    Map body = {
      "uid": uid,
      "cid": cid,
    };
    try {
      var response = await http.post(Uri.parse(Config.baseUrl + Config.cCheck),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        return data;
      } else {}
    } catch (e) {}
  }

  double totalPayment = 0;
  double walletMain = 0;
  double walletValue = 0;

  WalletReport? rWallet;
  // Wallet Report Api
  Future wReport(uid) async {
    Map body = {
      'uid': uid,
    };
    try {
      var response = await http.post(
          Uri.parse(Config.baseUrl + Config.walletReport),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });
      print(" A  A  A A A A object");
      print(response.body);
      if (response.statusCode == 200) {
        rWallet = walletReportFromJson(response.body);
        walletMain = double.parse(rWallet!.wallet);
        totalPayment = fTotal + int.parse(totalTax);
        print(" A   A  $totalPayment");
        Loading = false;
      } else {
        print(" A   A  $totalPayment");
      }
    } catch (e) {}
  }

  var id;
  var currencies;
  Future getvalidate() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    id = jsonDecode(sharedPreferences.getString('UserLogin')!);
    currencies = jsonDecode(sharedPreferences.getString('bannerData')!);
    Coupon(id['id']);
    wReport(id['id']);
    getStatus();
  }

  var car;
  var name;
  var tax;
  var totalTax;
  var fTotal;
  bool isLoads = false;
  cData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    car = jsonDecode(prefs.getString('carinfo')!);
    print(car);
    name = jsonDecode(prefs.getString('UserLogin')!);
    print('UserLogin  $name');
    tax = jsonDecode(prefs.getString('bannerData')!);
    total = [
      (double.parse(widget.toggle == true
              ? car['car_rent_price_driver']
              : car['car_rent_price']) *
          num.parse(car['price_type'] == '1' ? widget.hours : widget.days))
    ].reduce((a, b) => a * b);
    totalTax = int.parse(tax['tax']) * (total / 100);
    fTotal = total + totalTax + (total * 35 / 100);
    totalPayment = fTotal;
  }

  PayStackController payStackController = Get.put(PayStackController());
  String sk_key = "";

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifire.getbgcolor,
        elevation: 0,
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(12),
            child: Image.asset("assets/back.png",
                color: notifire.getwhiteblackcolor),
          ),
        ),
        title: Text("Review Summary".tr,
            style: TextStyle(
                fontFamily: FontFamily.europaBold,
                fontSize: 15,
                color: notifire.getwhiteblackcolor)),
      ),
      bottomNavigationBar: Container(
        height: 80,
        width: Get.size.width,
        alignment: Alignment.center,
        color: notifire.getbgcolor,
        child: GestButton(
          height: 50,
          Width: Get.width,
          margin: const EdgeInsets.all(8),
          buttoncolor: onbordingBlue,
          buttontext: isVerified ? 'Continue'.tr : " Please Verify to Continue",
          style: TextStyle(
              fontFamily: FontFamily.europaBold,
              color: WhiteColor,
              fontSize: 15),
          onclick: () {
            if (id["id"] == "0") {
              showGuestUserPopup(context);
            } else {
              if (isVerified) {
                totalPayment == 0
                    ? bNow(
                        car['id'],
                        id['id'],
                        widget.toggle == true
                            ? car['car_rent_price_driver']
                            : car['car_rent_price'],
                        car['price_type'] == '1' ? 'hr' : 'days',
                        widget.startDate,
                        widget.sTime,
                        widget.endDate,
                        widget.eTime,
                        coupon == 1 ? cList?.couponlist[inDex].id : '5',
                        cAmt ?? '0',
                        walletValue,
                        car['price_type'] == '1' ? widget.hours : widget.days,
                        total.toStringAsFixed(2),
                        tax['tax'],
                        totalTax,
                        totalPayment.toStringAsFixed(2),
                        gPayment?.paymentdata[0].id,
                        "0",
                        car['type_id'],
                        car['brand_id'],
                        widget.toggle == true ? 'With' : 'Without',
                        car['city_id'])
                    : showModalBottomSheet(
                        backgroundColor: notifire.getbgcolor,
                        isDismissible: false,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                topRight: Radius.circular(15))),
                        context: context,
                        builder: (BuildContext context) {
                          return StatefulBuilder(builder: (context, setState) {
                            return Scaffold(
                              backgroundColor: Colors.transparent,
                              bottomNavigationBar: Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10, left: 10, right: 10),
                                child: Container(
                                  height: 45,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: notifire.getbgcolor,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStatePropertyAll(
                                                onbordingBlue),
                                        shape: const MaterialStatePropertyAll(
                                            RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15))))),
                                    onPressed: () {
                                      FirebaseAnalytics.instance
                                          .logEvent(name: "stripe_selected");
                                      if (gPayment
                                              ?.paymentdata[payment].title ==
                                          "Stripe") {
                                        Get.back();
                                        makePayment((totalPayment / 156)
                                            .toStringAsFixed(2)
                                            .replaceAll(
                                              '.00',
                                              '',
                                            ));
                                      }
                                    },
                                    child: Center(
                                      child: RichText(
                                          text: TextSpan(children: [
                                        TextSpan(
                                            text: 'Continue'.tr,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                      ])),
                                    ),
                                  ),
                                ),
                              ),
                              body: Loading
                                  ? loader()
                                  : Container(
                                      height: 450,
                                      decoration: BoxDecoration(
                                          color: notifire.getbgcolor,
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15))),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            const SizedBox(height: 13),
                                            Center(
                                                child: Text(
                                                    'Payment Gateway Method'.tr,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18,
                                                        color: notifire
                                                            .getwhiteblackcolor))),
                                            const SizedBox(height: 4),
                                            Expanded(
                                              child: ListView.separated(
                                                  separatorBuilder:
                                                      (context, index) {
                                                    return const SizedBox(
                                                        width: 0);
                                                  },
                                                  shrinkWrap: true,
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount: gPayment!
                                                      .paymentdata.length,
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          payment = index;
                                                          sk_key = gPayment!
                                                              .paymentdata[
                                                                  index]
                                                              .attributes
                                                              .toString()
                                                              .split(",")
                                                              .last;
                                                          // paymentmethodId = from12.paymentdata[index].id;
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 90,
                                                        margin: const EdgeInsets
                                                            .only(
                                                            left: 10,
                                                            right: 10,
                                                            top: 6,
                                                            bottom: 7),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color: payment ==
                                                                      index
                                                                  ? onbordingBlue
                                                                  : Colors.grey
                                                                      .withOpacity(
                                                                          0.4)),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                        ),
                                                        child: Center(
                                                          child: ListTile(
                                                            leading: Transform
                                                                .translate(
                                                              offset:
                                                                  const Offset(
                                                                      -5, 0),
                                                              child: Container(
                                                                height: 100,
                                                                width: 60,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              15),
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.4)),
                                                                ),
                                                                child: Image
                                                                    .network(
                                                                        "${Config.imgUrl}${gPayment?.paymentdata[index].img}"),
                                                              ),
                                                            ),
                                                            title: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          4),
                                                              child: Text(
                                                                gPayment!
                                                                    .paymentdata[
                                                                        index]
                                                                    .title,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: notifire
                                                                        .getwhiteblackcolor),
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                            subtitle: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          4),
                                                              child: Text(
                                                                gPayment!
                                                                    .paymentdata[
                                                                        index]
                                                                    .subtitle,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: notifire
                                                                        .getwhiteblackcolor),
                                                                maxLines: 2,
                                                              ),
                                                            ),
                                                            trailing: Radio(
                                                              value: payment ==
                                                                      index
                                                                  ? true
                                                                  : false,
                                                              fillColor:
                                                                  MaterialStatePropertyAll(
                                                                      onbordingBlue),
                                                              groupValue: true,
                                                              onChanged:
                                                                  (value) {
                                                                payment = index;
                                                                setState(() {
                                                                  // selectedOption = value.toString();
                                                                  // selectBoring = from12.paymentdata[index].img;
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                            );
                          });
                        },
                      );
              } else {
                Get.to(const VerificationScreen());
              }
            }
          },
        ),
      ),
      body: Loading
          ? loader()
          : SizedBox(
              height: Get.size.height,
              width: Get.size.width,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 100,
                        width: Get.size.width,
                        child: Row(
                          children: [
                            Container(
                              height: 130,
                              width: 130,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey.withOpacity(0.10),
                                image: DecorationImage(
                                    image: NetworkImage(car['car_img']),
                                    fit: BoxFit.cover),
                              ),
                            ),
                            SizedBox(width: Get.width / 30),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        height: 30,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.grey.withOpacity(0.10),
                                        ),
                                        child: Center(
                                            child: Text(car['car_type_title'],
                                                style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.europaWoff,
                                                    color: onbordingBlue,
                                                    fontSize: 14))),
                                      ),
                                      const Spacer(),
                                      Image.asset(Appcontent.star1, height: 16),
                                      const SizedBox(width: 5),
                                      Text(car['car_rating'],
                                          style: const TextStyle(
                                              fontFamily: FontFamily.europaWoff,
                                              color: Colors.grey,
                                              fontSize: 14)),
                                    ],
                                  ),
                                  Text(car['car_title'],
                                      style: TextStyle(
                                          fontFamily: FontFamily.europaBold,
                                          fontSize: 16,
                                          color: notifire.getwhiteblackcolor)),
                                  RichText(
                                      text: TextSpan(
                                    children: [
                                      TextSpan(
                                          text:
                                              '${currencies['currency']}${widget.toggle == true ? car['car_rent_price_driver'] : car['car_rent_price']}',
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: onbordingBlue,
                                              fontFamily:
                                                  FontFamily.europaBold)),
                                      TextSpan(
                                          text:
                                              '/${car['price_type'] == '1' ? 'hr'.tr : 'days'.tr}',
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.grey,
                                              fontFamily:
                                                  FontFamily.europaWoff)),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: Get.height / 50),

                      summery(
                          title: 'Pick-Up Date & Time'.tr,
                          subtitle: '${widget.startDate} | ${widget.Picktime}'),
                      const SizedBox(height: 15),
                      summery(
                          title: 'Return Date & Time'.tr,
                          subtitle: '${widget.endDate} | ${widget.returnTime}'),
                      const SizedBox(height: 15),
                      // summery(title: 'Book with Driver'.tr, subtitle: widget.toggle == true ? 'With Driver'.tr : 'Without Driver'.tr),
                      // Apply Coupon
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (coupon == 0) {
                                    showModalBottomSheet(
                                      backgroundColor: notifire.getbgcolor,
                                      elevation: 0,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(15),
                                              topRight: Radius.circular(15))),
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Loading
                                            ? loader()
                                            : StatefulBuilder(
                                                builder: (context, setState) {
                                                return Container(
                                                  decoration: BoxDecoration(
                                                    color: notifire.getbgcolor,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    15),
                                                            topRight:
                                                                Radius.circular(
                                                                    15)),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 20),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        ListView.separated(
                                                            separatorBuilder:
                                                                (context, index) {
                                                              return const SizedBox(
                                                                  width: 0,
                                                                  height: 15);
                                                            },
                                                            shrinkWrap: true,
                                                            scrollDirection:
                                                                Axis.vertical,
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount: cList!
                                                                .couponlist
                                                                .length,
                                                            itemBuilder:
                                                                (BuildContextcontext,
                                                                    int index) {
                                                              inDex = index;
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10,
                                                                        right:
                                                                            10),
                                                                child: Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      height:
                                                                          60,
                                                                      width: 60,
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              5),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(15),
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.4)),
                                                                      ),
                                                                      child: Image
                                                                          .network(
                                                                              "${Config.imgUrl}${cList?.couponlist[index].couponImg}"),
                                                                    ),
                                                                    Flexible(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                5),
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(cList!.couponlist[index].couponTitle,
                                                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: notifire.getwhiteblackcolor, fontFamily: FontFamily.europaBold)),
                                                                            const SizedBox(height: 2),
                                                                            Text(
                                                                              cList!.couponlist[index].couponSubtitle,
                                                                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: notifire.getwhiteblackcolor, fontFamily: FontFamily.europaWoff),
                                                                              maxLines: 1,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                                                              child: ReadMoreText(
                                                                                cList!.couponlist[index].cDesc,
                                                                                style: TextStyle(color: notifire.getwhiteblackcolor, fontSize: 12, fontFamily: FontFamily.europaWoff),
                                                                                trimLines: 2,
                                                                                colorClickableText: Colors.pink,
                                                                                trimMode: TrimMode.Line,
                                                                                trimCollapsedText: 'Show more',
                                                                                trimExpandedText: ' Show less',
                                                                                moreStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: onbordingBlue, fontFamily: FontFamily.europaBold),
                                                                                lessStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: onbordingBlue, fontFamily: FontFamily.europaBold),
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Image.asset(Appcontent.coupon, height: 15, width: 15, color: notifire.getwhiteblackcolor),
                                                                                        const SizedBox(width: 5),
                                                                                        Text('Coupon Code', style: TextStyle(fontSize: 12, fontFamily: FontFamily.europaBold, color: notifire.getwhiteblackcolor)),
                                                                                      ],
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 20),
                                                                                      child: Text(cList!.couponlist[index].couponCode, style: TextStyle(fontSize: 12, fontFamily: FontFamily.europaWoff, color: notifire.getwhiteblackcolor)),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(width: 15),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Image.asset(Appcontent.coupon, height: 15, width: 15, color: notifire.getwhiteblackcolor),
                                                                                        const SizedBox(width: 5),
                                                                                        Text('Coupon Value', style: TextStyle(fontSize: 12, fontFamily: FontFamily.europaBold, color: notifire.getwhiteblackcolor)),
                                                                                      ],
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 20),
                                                                                      child: Text('${currencies['currency']}${cList!.couponlist[index].couponVal}', style: TextStyle(fontSize: 12, fontFamily: FontFamily.europaWoff, color: notifire.getwhiteblackcolor)),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const SizedBox(height: 5),
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Icon(Icons.timer_outlined, size: 15, color: notifire.getwhiteblackcolor),
                                                                                        const SizedBox(width: 5),
                                                                                        Text('Expiry Date', style: TextStyle(fontSize: 10, color: notifire.getwhiteblackcolor, fontFamily: FontFamily.europaBold)),
                                                                                      ],
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 19),
                                                                                      child: Text(cList!.couponlist[index].expireDate.toString().split(" ").first, style: TextStyle(fontSize: 10, color: notifire.getwhiteblackcolor, fontFamily: FontFamily.europaWoff)),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const SizedBox(width: 10),
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        Image(image: const AssetImage(Appcontent.credit), height: 15, width: 15, color: notifire.getwhiteblackcolor),
                                                                                        const SizedBox(
                                                                                          width: 5,
                                                                                        ),
                                                                                        Text('Min Amount'.tr, style: TextStyle(fontSize: 10, color: notifire.getwhiteblackcolor, fontFamily: FontFamily.europaBold)),
                                                                                      ],
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(left: 19),
                                                                                      child: Text('${currencies['currency']}${cList!.couponlist[index].minAmt}', style: TextStyle(fontSize: 10, color: notifire.getwhiteblackcolor, fontFamily: FontFamily.europaWoff)),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                const Spacer(),
                                                                                fTotal > int.parse(cList!.couponlist[index].minAmt)
                                                                                    ? InkWell(
                                                                                        onTap: () async {
                                                                                          Check(id['id'], cList!.couponlist[index].id).then((value) {
                                                                                            if (value['ResponseCode'] == "200") {
                                                                                              setState(() {
                                                                                                coupon = 1;
                                                                                                cAmt = double.parse(cList!.couponlist[index].couponVal);
                                                                                                coupon == 0 ? fTotal -= cAmt : totalPayment -= cAmt;
                                                                                              });
                                                                                              Fluttertoast.showToast(msg: value['ResponseMsg']);
                                                                                              Get.back(result: 1);
                                                                                            } else {
                                                                                              Fluttertoast.showToast(msg: value['ResponseMsg']);
                                                                                            }
                                                                                          });
                                                                                        },
                                                                                        child: Container(
                                                                                          height: 30,
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                          decoration: BoxDecoration(
                                                                                            color: onbordingBlue,
                                                                                            borderRadius: BorderRadius.circular(10),
                                                                                          ),
                                                                                          child: Center(child: Text('Apply'.tr, style: const TextStyle(color: Colors.white, fontFamily: FontFamily.europaBold))),
                                                                                        ),
                                                                                      )
                                                                                    : Container(
                                                                                        height: 30,
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                                                                        decoration: BoxDecoration(
                                                                                          color: Colors.grey,
                                                                                          borderRadius: BorderRadius.circular(10),
                                                                                        ),
                                                                                        child: Center(child: Text('Not Apply'.tr, style: const TextStyle(color: Colors.white, fontFamily: FontFamily.europaWoff, fontSize: 13))),
                                                                                      ),
                                                                                const SizedBox(width: 10),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }),
                                                        const SizedBox(
                                                            height: 20),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              });
                                      },
                                    ).then((value) {
                                      setState(() {
                                        coupon = value;
                                      });
                                    });
                                  } else {}
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        leading: Image(
                                            image: const AssetImage(
                                                Appcontent.percent),
                                            height: 25,
                                            width: 25,
                                            color: notifire.getwhiteblackcolor),
                                        title: Transform.translate(
                                            offset: const Offset(-10, 0),
                                            child: Text('Apply Coupon'.tr,
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: notifire
                                                        .getwhiteblackcolor,
                                                    fontFamily: FontFamily
                                                        .europaBold))),
                                        trailing: Icon(
                                            Icons.keyboard_arrow_right,
                                            color: notifire.getwhiteblackcolor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              coupon == 1
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const SizedBox(width: 15),
                                              Text('Coupon Applied !'.tr,
                                                  style: TextStyle(
                                                      color:
                                                          notifire.getgreycolor,
                                                      fontFamily:
                                                          FontFamily.europaWoff,
                                                      fontSize: 17)),
                                              const Spacer(),
                                              InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      coupon = 0;
                                                      coupon == 0
                                                          ? totalPayment += cAmt
                                                          : fTotal += cAmt;
                                                    });
                                                  },
                                                  child: Text('Remove'.tr,
                                                      style: const TextStyle(
                                                          color: Colors.red,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15))),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                        ],
                                      ),
                                    )
                                  : const SizedBox()
                            ],
                          ),
                        ),
                      ),
                      // Pay Wallet
                      rWallet?.wallet == "0"
                          ? const SizedBox()
                          : Container(
                              width: MediaQuery.of(context).size.width,
                              margin: const EdgeInsets.only(bottom: 15),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 5),
                                      Image.asset(Appcontent.card1,
                                          height: 25,
                                          width: 25,
                                          color: notifire.getwhiteblackcolor),
                                      const SizedBox(width: 15),
                                      Text('Pay from Wallet'.tr,
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: FontFamily.europaBold,
                                              color:
                                                  notifire.getwhiteblackcolor)),
                                      const Spacer(),
                                      Transform.scale(
                                        scale: 0.8,
                                        child: CupertinoSwitch(
                                          value: light,
                                          activeColor: onbordingBlue,
                                          onChanged: (bool value) {
                                            setState(() {
                                              light = value;
                                            });
                                            if (value) {
                                              print("$fTotal");
                                              if (fTotal > walletMain) {
                                                walletValue = walletMain;
                                                totalPayment -= walletValue;

                                                walletMain = 0;
                                              } else {
                                                walletValue = totalPayment;
                                                totalPayment -= walletValue;
                                                walletMain -= fTotal;

                                                double good = double.parse(
                                                    rWallet!.wallet);

                                                walletMain =
                                                    (good - walletValue);
                                              }
                                            } else {
                                              walletValue = 0;
                                              walletMain =
                                                  double.parse(rWallet!.wallet);
                                              totalPayment = fTotal;
                                              coupon = 0;
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const SizedBox(width: 5),
                                      Image.asset(Appcontent.card1,
                                          height: 25,
                                          width: 25,
                                          color: notifire.getwhiteblackcolor),
                                      const SizedBox(width: 15),
                                      Text('My Wallet'.tr,
                                          style: TextStyle(
                                              fontFamily: FontFamily.europaBold,
                                              fontSize: 15,
                                              color:
                                                  notifire.getwhiteblackcolor)),
                                      const Spacer(),
                                      InkWell(
                                          onTap: () {
                                            print(
                                                'WALLET --> ${rWallet?.wallet}');
                                            print(
                                                'WALLET MAIN --> ${walletMain.toStringAsFixed(2)}');
                                          },
                                          child: Text(
                                              '${currencies['currency']}${light ? walletMain.toStringAsFixed(2) : rWallet?.wallet}',
                                              style: const TextStyle(
                                                  fontFamily:
                                                      FontFamily.europaBold,
                                                  fontSize: 16,
                                                  color: Color(0xff235DFF)))),
                                      const SizedBox(width: 5),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                      summery(
                          title: car['price_type'] == '1'
                              ? 'Total Hours'.tr
                              : 'Total days',
                          subtitle: car['price_type'] == '1'
                              ? '${widget.hours} Hours'
                              : '${widget.days} Days'),
                      const SizedBox(height: 15),
                      summery(
                          title: widget.toggle == true
                              ? 'Amount (With Driver)'.tr
                              : 'Amount'.tr,
                          subtitle:
                              '${currencies['currency']}${NumberFormat('#,##0.00').format(total)} JMD'),
                      const SizedBox(height: 15),
                      summery(
                          title: 'Tax (${tax['tax']} %)',
                          subtitle:
                              '${currencies['currency']}${NumberFormat('#,##0.00').format(totalTax)} JMD'),
                      const SizedBox(height: 15),
                      summery(
                          title: 'Booking Fee (35%)',
                          subtitle:
                              '${currencies['currency']}${NumberFormat('#,##0.00').format(total * 35 / 100)} JMD'),

                      coupon == 1
                          ? const SizedBox(height: 15)
                          : const SizedBox(),
                      coupon == 1
                          ? summery(
                              title: 'Coupon',
                              subtitle: '${currencies['currency']}$cAmt')
                          : const SizedBox(),
                      coupon == 1
                          ? const SizedBox(height: 10)
                          : const SizedBox(),
                      light ? const SizedBox(height: 10) : const SizedBox(),
                      light
                          ? Row(
                              children: [
                                Text('Wallet'.tr,
                                    style: TextStyle(
                                        fontFamily: FontFamily.europaWoff,
                                        color: notifire.getgreycolor,
                                        fontSize: 15)),
                                const Spacer(),
                                light
                                    ? Text(
                                        '${currencies['currency']}$walletValue',
                                        style: const TextStyle(
                                            fontFamily: FontFamily.europaBold,
                                            fontSize: 16,
                                            color: Color(0xff235DFF)))
                                    : Text(
                                        '${currencies['currency']}$walletMain',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Color(0xff235DFF))),
                              ],
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 10,
                          thickness: 1,
                          color: notifire.getgreycolor,
                        ),
                      ),
                      InkWell(
                          onTap: () {
                            coupon = 0;
                            cAmt =
                                double.parse(cList!.couponlist[inDex].minAmt);
                            print(totalPayment.toStringAsFixed(2));
                          },
                          child: summery(
                              title: 'Total'.tr,
                              subtitle:
                                  '${currencies['currency']}${NumberFormat('#,##0.00').format(totalPayment)} JMD')),
                      summery(
                          title: 'Total in USD - you will be charged in usd',
                          subtitle:
                              '${currencies['currency']}${(totalPayment / 156).toStringAsFixed(2)} USD'),
                      summery(title: 'Exchange Rate', subtitle: '156:1'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget summery({required String title, required String subtitle}) {
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                fontFamily: FontFamily.europaWoff,
                color: notifire.getgreycolor,
                fontSize: 15)),
        const Spacer(),
        Text(subtitle,
            style: TextStyle(
                fontFamily: FontFamily.europaWoff,
                color: notifire.getwhiteblackcolor,
                fontSize: 15)),
      ],
    );
  }

  Map<String, dynamic>? paymentIntent;
  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, 'USD');

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Carvo Share'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        print(paymentIntent!["id"]);
        FirebaseAnalytics.instance
            .logEvent(name: "payment_proceed", parameters: {
          "carid": car['id'],
          "userid": id['id'],
          "amount": totalPayment.toStringAsFixed(2),
          "paymentintent": paymentIntent!["id"],
        });
        bNow(
            car['id'],
            id['id'],
            widget.toggle == true
                ? car['car_rent_price_driver']
                : car['car_rent_price'],
            car['price_type'] == '1' ? 'hr' : 'days',
            widget.startDate,
            widget.sTime,
            widget.endDate,
            widget.eTime,
            coupon == 1 ? cList?.couponlist[inDex].id : '5',
            cAmt ?? '0',
            walletValue,
            car['price_type'] == '1' ? widget.hours : widget.days,
            total.toStringAsFixed(2),
            tax['tax'],
            totalTax,
            totalPayment.toStringAsFixed(2),
            gPayment?.paymentdata[0].id,
            paymentIntent!["id"],
            car['type_id'],
            car['brand_id'],
            widget.toggle == true ? 'With' : 'Without',
            car['city_id']);

        paymentIntent = null;
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    print(amount);
    final int calculatedAmout = ((double.parse(amount)) * 100).toInt();
    print(calculatedAmout);
    return calculatedAmout.toString();
  }
}
