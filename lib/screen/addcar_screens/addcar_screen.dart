// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, empty_catches, avoid_print, non_constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:carlink/model/bookrange_modal.dart';
import 'package:carlink/model/carbrand.dart';
import 'package:carlink/model/cartype_modal.dart';
import 'package:carlink/model/facillity_modal.dart';
import 'package:carlink/screen/verification_screens/verification_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/Dark_lightmode.dart';
import 'package:carlink/utils/common.dart';
import 'package:carlink/utils/common_textfield.dart';
import 'package:carlink/utils/config.dart';
import 'package:carlink/utils/fontfameli_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../model/citylist_modal.dart';
import '../../model/mycarlist_modal.dart';
import '../../utils/App_content.dart';

class AddCarScreen extends StatefulWidget {
  final String? uid;
  final String? id;
  final String? recordId;
  final String? title;
  const AddCarScreen({super.key, this.id, this.recordId, this.title, this.uid});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

String dropId = "";
String? selectedValue;
String? isApproveValue;
String? rejectCommentValue;

class _AddCarScreenState extends State<AddCarScreen> {
  late ColorNotifire notifire;
  late FacilitylistModal facilitylistModal;
  GlobalKey<AutoCompleteTextFieldState<dynamic>> key1 = GlobalKey();
  bool loading = true;
  XFile? selectImage;
  ImagePicker picker = ImagePicker();
  ImagePicker picker1 = ImagePicker();
  bool isVerified = false;
  BookRangeModal? bookRangeModal;

  late DateRangePickerController dController;
  final _scrollController = ScrollController();

  List<String> _unavailableDates = [];

  @override
  void initState() {
    // cityList();
    facilites();
    save();
    _getCurrentPosition();
    addCustomIcon();
    // type();
    // brand();
    print(_multiDatePickerValueWithDefaultValue);
    dController = DateRangePickerController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 1000) {
        print('scrolling distance: ${_scrollController.offset}');
      }
    });
    super.initState();
  }

  Future<void> getStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isVerified = prefs.getBool("isVerified") ?? false;
    print(isVerified);
  }

  Future camera() async {
    XFile? file = await picker.pickImage(source: ImageSource.camera);
    if (file != null) {
      setState(() {
        image.add(file.path);
      });
    } else {
      Fluttertoast.showToast(msg: 'image pick in not Camera!!');
    }
  }

  Future gallery() async {
    XFile? file = await picker1.pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() {
        image.add(file.path);
      });
    } else {
      Fluttertoast.showToast(msg: 'image not selected!!');
    }
  }

  List status = [
    'Yes'.tr,
    'No'.tr,
  ];
  List carGear = [
    'Auto'.tr,
    'Manual'.tr,
  ];
  var pType;
  var fType;
  List price = [
    'Days'.tr,
    //'Hourly'.tr,
  ];
  List fuel = [
    'Petrol'.tr,
    'Diesel'.tr,
    'Electric'.tr,
    'CNG'.tr,
    'Petrol & CNG'.tr,
  ];
  List publish = [
    'Publish'.tr,
    'Unpublish'.tr,
  ];
  bool isvalidate = false;
  bool isvalidate1 = false;
  bool isvalidate2 = false;
  bool isvalidate3 = false;
  bool isvalidate4 = false;
  bool isvalidate5 = false;
  bool isvalidate6 = false;
  bool isvalidate7 = false;
  bool isvalidate8 = false;
  bool isvalidate9 = false;
  bool isLoading = true;

  Widget _buildMultiDatePickerWithValue() {
    final config = CalendarDatePicker2Config(
      dayModeScrollDirection: Axis.vertical,
      disableMonthPicker: true,
      calendarType: CalendarDatePicker2Type.multi,
      selectedDayHighlightColor: Colors.red.shade900,
    );
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: CalendarDatePicker2(
                config: config,
                value: _multiDatePickerValueWithDefaultValue,
                onValueChanged: (dates) {
                  setState(() {
                    _multiDatePickerValueWithDefaultValue = dates;
                    _unavailableDates =
                        _multiDatePickerValueWithDefaultValue.map((date) {
                      return date != null
                          ? DateFormat("yyyy-MM-dd")
                              .format(date) // Convert to "yyyy-MM-dd"
                          : '';
                    }).toList();
                    print(_unavailableDates);
                  });
                }),
          ),
        ],
      ),
    );
  }

  Future facilites() async {
    print("facility executed");
    try {
      setState(() {
        loading = true;
      });
      var response = await http
          .post(Uri.parse('${Config.baseUrl}${Config.facilityList}'), headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        setState(() {
          print("*********");
          print(response.body);
          facilitylistModal = facilitylistModalFromJson(response.body);
          type();
        });
      } else {}
    } catch (e) {}
  }

  Map<String, String> cityDataList = {};

  Future cityList() async {
    print("city executed");
    setState(() {
      loading = true;
    });

    try {
      var response =
          await http.post(Uri.parse(Config.baseUrl + Config.city), headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        cities = cityListFromJson(response.body);

        for (var city in data['citylist']) {
          cityDataList[city['title']] = city['id'];
        }
        if (dropId.isEmpty) {
          setState(() {
            dropId = "";
          });
          print("drop id is empty");
        } else {
          cityDataList.forEach((key, value) {
            if (value == dropId) {
              setState(() {
                selectedValue = key;
              });
              print(selectedValue);
            }
          });
        }

        setState(() {
          loading = false;
        });

        return data;
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
      });
    }
  }

  CarType? cType;
  Future type() async {
    print("type executed");
    Map body = {};
    try {
      setState(() {
        loading = true;
      });
      var response = await http.post(Uri.parse(Config.baseUrl + Config.carType),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        setState(() {
          cType = carTypeFromJson(response.body);
          brand();
        });
        return data;
      } else {}
    } catch (e) {}
  }

  CarBrand? cBrand;
  Future brand() async {
    print("brand executed");
    try {
      setState(() {
        loading = true;
      });
      var response = await http
          .post(Uri.parse(Config.baseUrl + Config.carBrand), headers: {
        'Content-Type': 'application/json',
      });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        setState(() {
          cBrand = carBrandFromJson(response.body);
          // loading = false;
          cityList();
        });
        return data;
      } else {}
    } catch (e) {}
  }

  Future addCar(
    carNumber,
    status,
    rating,
    seat,
    carAc,
    carTitle,
    dName,
    dMobile,
    gear,
    facility,
    type,
    brand,
    available,
    rPrice,
    rPriceDriver,
    engine,
    price,
    fuel,
    desc,
    pickAddress,
    lat,
    lng,
    totalKm,
    size,
    uId,
    minHrs,
    unavalibaleDates,
  ) async {
    var headers = {'Cookie': 'PHPSESSID=36pnj5phm83llglrqid2qnuquk'};
    var request = http.MultipartRequest(
        'POST', Uri.parse('${Config.baseUrl}${Config.addCar}'));
    request.fields.addAll({
      'car_number': carNumber,
      'car_status': status,
      'car_rating': "5",
      'total_seat': seat,
      'car_ac': carAc,
      'car_title': carTitle,
      'driver_name': dName,
      'driver_mobile': dMobile,
      'car_gear': gear,
      'car_facility': facility,
      'car_type': type,
      'car_brand': brand,
      'car_available': available,
      'car_rent_price': rPrice,
      'car_rent_price_driver': "1500",
      'engine_hp': "1500",
      'price_type': "0",
      'fuel_type': fuel,
      'car_desc': desc,
      'pick_address': pickAddress,
      'pick_lat': lat.toString(),
      'pick_lng': lng.toString(),
      'total_km': totalKm,
      'size': size,
      'uid': uId,
      'min_hrs': minHrs,
      "unavailable_dates": unavalibaleDates,
    });
    for (int a = 0; a < image.length; a++) {
      request.files
          .add(await http.MultipartFile.fromPath('carphoto$a', image[a]));
      print(image[a]);
    }
    request.headers.addAll(headers);
    print(request.fields);

    try {
      http.StreamedResponse response = await request.send();
      print(response);
      if (response.statusCode == 200) {
        var data = jsonDecode(await response.stream.bytesToString());
        return data;
      } else {
        var data = jsonDecode(await response.stream.bytesToString());
        print("Im here bro");
        print(data);
        return data;
      }
    } catch (e) {
      print(e);
    }
  }

  Future update({
    required String number,
    required String status,
    required String rate,
    required String seat,
    required String ac,
    required String cName,
    required String dName,
    required String mobileNo,
    required String carGear,
    required String carFacility,
    required String type,
    required String brand,
    required String location,
    required String without,
    required String withrent,
    required String engine,
    required String price,
    required String fuel,
    required String desc,
    required String address,
    required String lat,
    required String long,
    required String totalKm,
    required String size,
    required String imgList,
    required String minHrs,
    required String isApprove,
    String? unavailableDates,
  }) async {
    var headers = {'Cookie': 'PHPSESSID=50rkm1fprfmse0j5lmfhntcqlf'};
    var request = http.MultipartRequest(
        'POST', Uri.parse('${Config.baseUrl}${Config.updateCar}'));
    request.fields.addAll({
      'car_number': number,
      'car_status': status,
      'car_rating': "5",
      'total_seat': seat,
      'car_ac': ac,
      'car_title': cName,
      'driver_name': dName,
      'driver_mobile': mobileNo,
      'car_gear': carGear,
      'car_facility': carFacility,
      'car_type': type,
      'car_brand': brand,
      'car_available': location,
      'car_rent_price': without,
      'car_rent_price_driver': withrent,
      'engine_hp': engine,
      'price_type': "0",
      'fuel_type': fuel,
      'car_desc': desc,
      'pick_address': address,
      'pick_lat': lat,
      'pick_lng': long,
      'total_km': totalKm,
      'uid': widget.uid == "0" ? "0" : userData['id'],
      'record_id': widget.recordId.toString(),
      'size': size,
      'imlist': imgList,
      'min_hrs': minHrs,
      "is_approve": "0",
      "unavailable_dates": unavailableDates!,
    });
    print(request.fields);
    for (int a = 0; a < image.length; a++) {
      request.files
          .add(await http.MultipartFile.fromPath('carphoto$a', image[a]));
      print(image[a]);
    }

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      var data = jsonDecode(await response.stream.bytesToString());
      return data;
    } else {
      var data = jsonDecode(await response.stream.bytesToString());
      return data;
    }
  }

  CityList? cities;

  var selectIndex;
  var selectType;
  var selectBrand;
  var selectStatus;

  @override
  void dispose() {
    image.clear();
    netImg.clear();
    nameController.dispose();
    nameController.dispose();
    cNumberController.dispose();
    driverController.dispose();
    mobileController.dispose();
    seatController.dispose();
    locationController.dispose();
    withoutRent.dispose();
    withRent.dispose();
    engineController.dispose();
    latController.dispose();
    lngController.dispose();
    totalKmController.dispose();
    descController.dispose();
    addressController.dispose();
    minimumController.dispose();
    super.dispose();
  }

  var userData;

  save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userData = jsonDecode(prefs.getString('UserLogin') ?? '0');

    button == true ? null : listCar(widget.uid == "0" ? "0" : userData['id']);
    print('+ + + + + ${widget.uid == "0" ? "0" : userData['id']}');
    getStatus();
  }

  List temp = [];
  var rId;
  MyCarListModal? myCarListModal;
  Future listCar(uId) async {
    Map body = {
      "uid": uId,
    };
    try {
      var response = await http.post(Uri.parse(Config.baseUrl + Config.carList),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });
      print(response.body);
      if (response.statusCode == 200) {
        setState(() {
          myCarListModal = myCarListModalFromJson(response.body);
        });
        for (int i = 0; i < myCarListModal!.mycarlist.length; i++) {
          temp.add(0);
        }
        netImg = myCarListModal!
            .mycarlist[int.parse(widget.id.toString())].carImg
            .toString()
            .split("\$;");
        setState(() {});
        var data = jsonDecode(response.body.toString());
        return data;
      } else {}
    } catch (e) {}
  }

  final _formKey = GlobalKey<FormState>();
  bool load = false;
  bool load1 = false;
  Future dashboard(uId) async {
    Map body = {
      "uid": uId,
    };
    try {
      var response = await http.post(
          Uri.parse(Config.baseUrl + Config.dashboard),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        return data;
      } else {
        var data = jsonDecode(response.body.toString());
        return data;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String text = "";
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // Add Car and Update Car button
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: button == true
            ? load
                ? loader()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: onbordingBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        fixedSize: Size(Get.width, 50)),
                    onPressed: () {
                      if (isVerified) {
                        setState(() {
                          if (carStatus != null) {
                            isvalidate = false;
                            print("car status $carStatus");
                          } else {
                            isvalidate = true;
                          }
                          if (image.isNotEmpty) {
                            isvalidate1 = false;
                            print("car image $image");
                          } else {
                            isvalidate1 = true;
                          }
                          if (ac != null) {
                            isvalidate2 = false;
                            print("car ca $ac");
                          } else {
                            isvalidate2 = true;
                          }
                          if (gear != null) {
                            isvalidate2 = false;
                            print("car gear $gear");
                          } else {
                            isvalidate3 = true;
                          }
                          if (multiSelect.isNotEmpty) {
                            isvalidate4 = false;
                            print("car multiselect $multiSelect");
                          } else {
                            isvalidate4 = true;
                          }
                          if (carType != null) {
                            isvalidate5 = false;
                            print("car type $carType");
                          } else {
                            isvalidate5 = true;
                          }
                          if (carBrand != null) {
                            isvalidate6 = false;
                            print("car brand $carBrand");
                          } else {
                            isvalidate6 = true;
                          }
                          // if (carPrice != null) {
                          //   isvalidate7 = false;
                          //   print("car price $carPrice");
                          // } else {
                          //   isvalidate7 = true;
                          // }
                          if (carFuel != null) {
                            isvalidate8 = false;
                            print("car fuel $carFuel");
                          } else {
                            isvalidate8 = true;
                          }
                        });
                        if (_formKey.currentState!.validate() &&
                            carStatus != null &&
                            image.isNotEmpty &&
                            gear != null &&
                            multiSelect.isNotEmpty &&
                            carType != null &&
                            carBrand != null &&
                            // carPrice != null &&
                            carFuel != null) {
                          setState(() {
                            load = true;
                          });

                          addCar(
                                  cNumberController.text,
                                  carStatus,
                                  "5",
                                  seatController.text,
                                  ac,
                                  nameController.text,
                                  driverController.text,
                                  mobileController.text,
                                  gear,
                                  multiSelect.join(','),
                                  carType,
                                  carBrand,
                                  dropId,
                                  withoutRent.text,
                                  withRent.text,
                                  engineController.text,
                                  carPrice,
                                  carFuel,
                                  descController.text,
                                  addressController.text,
                                  lats ?? _currentPosition?.latitude,
                                  lng ?? _currentPosition?.longitude,
                                  totalKmController.text,
                                  image.length.toString(),
                                  widget.uid == "0" ? "0" : userData['id'],
                                  minimumController.text,
                                  jsonEncode(_unavailableDates))
                              .then((value) {
                            print(value);
                            if (value["ResponseCode"] == "200") {
                              FirebaseAnalytics.instance
                                  .logEvent(name: "car_added", parameters: {
                                "userid":
                                    widget.uid == "0" ? "0" : userData['id'],
                              });
                              Fluttertoast.showToast(msg: value["ResponseMsg"]);
                              listCar(widget.uid == "0" ? "0" : userData['id']);
                              dashboard(
                                  widget.uid == "0" ? "0" : userData['id']);
                              setState(() {
                                load = false;
                              });
                              Get.back();
                            } else {
                              setState(() {
                                load = false;
                              });
                              Fluttertoast.showToast(msg: value["ResponseMsg"]);
                            }
                          });
                        } else {
                          Fluttertoast.showToast(
                              msg: 'Please some your text!!');
                        }
                      } else {
                        Get.to(const VerificationScreen());
                      }
                    },
                    child: Text(
                        isVerified ? 'Add Car'.tr : "Please Verify to Continue",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: FontFamily.europaBold)),
                  )
            : load1
                ? loader()
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: onbordingBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        fixedSize: Size(Get.width, 50)),
                    onPressed: () {
                      setState(() {
                        if (image.isEmpty) {
                          isvalidate9 = false;
                        } else {
                          isvalidate9 = true;
                        }

                        if (carStatus != null) {
                          isvalidate = false;
                        } else {
                          isvalidate = true;
                        }
                        if (ac != null) {
                          isvalidate2 = false;
                        } else {
                          isvalidate2 = true;
                        }
                        if (gear != null) {
                          isvalidate2 = false;
                        } else {
                          isvalidate3 = true;
                        }
                        if (multiSelect.isNotEmpty) {
                          print(multiSelect);
                          isvalidate4 = false;
                        } else {
                          isvalidate4 = true;
                        }
                        if (carType != null) {
                          isvalidate5 = false;
                        } else {
                          isvalidate5 = true;
                        }
                        if (carBrand != null) {
                          isvalidate6 = false;
                        } else {
                          isvalidate6 = true;
                        }
                        // if (carPrice != null) {
                        //   isvalidate7 = false;
                        // } else {
                        //   isvalidate7 = true;
                        // }
                        if (carFuel != null) {
                          isvalidate8 = false;
                        } else {
                          isvalidate8 = true;
                        }
                      });
                      if (_formKey.currentState!
                              .validate() /* &&
                          carStatus != null &&
                          gear != null &&
                          multiSelect.isNotEmpty &&
                          carType != null &&
                          carBrand != null &&
                          carPrice != null &&
                          image.isNotEmpty&&
                          carFuel != null*/ /*commenting because this setstate function is likely duplicating the ifelse above, also, it is likely resetting the values to null*/
                          ) {
                        setState(() {
                          load1 = true;
                        });

                        update(
                                number: cNumberController.text,
                                status: carStatus,
                                rate: "5",
                                seat: seatController.text,
                                ac: ac,
                                cName: nameController.text,
                                dName: driverController.text,
                                mobileNo: mobileController.text,
                                carGear: gear,
                                carFacility: multiSelect.join(","),
                                type: carType,
                                brand: carBrand,
                                location: dropId,
                                without: withoutRent.text,
                                withrent: withRent.text,
                                engine: engineController.text,
                                price: carPrice,
                                fuel: carFuel,
                                desc: descController.text,
                                address: addressController.text,
                                lat: latController.text,
                                long: lngController.text,
                                totalKm: totalKmController.text,
                                size: image.length.toString(),
                                isApprove: '0',
                                imgList:
                                    netImg.isEmpty ? '0' : netImg.join('\$;'),
                                minHrs: minimumController.text,
                                unavailableDates: jsonEncode(_unavailableDates))
                            .then((value) {
                          print('!!!!!!!!!!!!!$value');
                          if (value["ResponseCode"] == "200") {
                            Fluttertoast.showToast(msg: value["ResponseMsg"]);
                            // edit(carName: nameController.text, carNumber: cNumberController.text, status: carStatus, uploadImage: image, AC: ac, carGear: gear, carFacility: multiSelect.toString(), type: carType, brand: carBrand, driverName: driverController.text, mobile: mobileController.text, rating: ratingController.text, seat: seatController.text, location: locationName.toString(), without: withoutRent.text, withrent: withRent.text, engine: engineController.text, pType: carPrice, fuel: carFuel, lat: latController.text, long: lngController.text, totalKm: totalKmController.text, desc: descController.text, address: addressController.text, minimum: minimumController.text);
                            setState(() {
                              load1 = false;
                            });
                            Get.back();
                          } else {
                            Fluttertoast.showToast(msg: value['ResponseMsg']);
                          }
                        });
                      } else {
                        Fluttertoast.showToast(msg: 'Please some your text!!');
                      }
                    },
                    child: Text('Update Car'.tr,
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: FontFamily.europaBold)),
                  ),
      ),
      appBar: AppBar(
        backgroundColor: onbordingBlue,
        elevation: 0,
        centerTitle: true,
        title: Text(
            button == true
                ? 'Car Information'.tr
                : '${'Car Edit'.tr} ${widget.title}'.tr,
            style: TextStyle(
                color: Colors.white,
                fontFamily: FontFamily.europaBold,
                fontSize: 18)),
      ),
      body: loading
          ? loader()
          : GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        isApproveValue == "2"
                            ? Align(
                                alignment: Alignment.center,
                                child: Container(
                                  color: Colors.red,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 8.0,
                                        bottom: 8.0,
                                        left: 32,
                                        right: 32),
                                    child: Text('Your Car is Rejected!',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: FontFamily.europaBold,
                                            fontSize: 15)),
                                  ),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 8,
                        ),
                        isApproveValue == "2"
                            ? Row(
                                children: [
                                  Text("Reason :",
                                      style: TextStyle(
                                          color: notifire.getwhiteblackcolor,
                                          fontFamily: FontFamily.europaBold,
                                          fontSize: 15)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 100,
                                    child: Text(rejectCommentValue!,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontFamily: FontFamily.europaBold,
                                            fontSize: 15)),
                                  ),
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: 8,
                        ),
                        textfield(
                            title: 'Car Name'.tr,
                            enterName: "Example: 2025 Toyota Yaris",
                            controller: nameController,
                            validate: 'Enter Car Name'.tr),
                        textfield(
                            title: 'License Plate'.tr,
                            enterName: 'Enter License Plate'.tr,
                            controller: cNumberController,
                            validate: 'Enter Car Number'.tr),

                        Text('Car Status'.tr,
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                            "Published means your car is visible to all users."),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: publish.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    setState(() {
                                      selectStatus = index;
                                      carStatus = index == 0 ? "1" : "0";
                                      print('+ ++ + ++  $carStatus');
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    margin: EdgeInsets.only(
                                        right: 10, top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                        color: carStatus ==
                                                (index == 0 ? "1" : "0")
                                            ? onbordingBlue
                                            : Colors.transparent,
                                        border:
                                            Border.all(color: onbordingBlue),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text(publish[index],
                                            style: TextStyle(
                                                color: carStatus ==
                                                        (index == 0 ? "1" : "0")
                                                    ? Colors.white
                                                    : onbordingBlue,
                                                fontFamily:
                                                    FontFamily.europaBold))),
                                  ),
                                );
                              }),
                        ),
                        isvalidate
                            ? Text('Please select a Status.'.tr,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13))
                            : SizedBox(),
                        Text('Car Image'.tr,
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              isDismissible: false,
                              backgroundColor: notifire.getbgcolor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(13))),
                              context: context,
                              builder: (context) {
                                return SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Text(
                                          "From where do you want to take the photo?"
                                              .tr,
                                          style: TextStyle(
                                              fontFamily: FontFamily.europaBold,
                                              fontSize: 20,
                                              color:
                                                  notifire.getwhiteblackcolor),
                                        ),
                                        SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                    fixedSize:
                                                        const Size(100, 50),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50)),
                                                    side: BorderSide(
                                                        color: greyScale)),
                                                onPressed: () {
                                                  gallery();
                                                  Get.back();
                                                },
                                                child: Text(
                                                  "Gallery".tr,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          FontFamily.europaBold,
                                                      fontSize: 15,
                                                      color: notifire
                                                          .getwhiteblackcolor),
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 13),
                                            Expanded(
                                              child: OutlinedButton(
                                                style: OutlinedButton.styleFrom(
                                                    fixedSize:
                                                        const Size(100, 50),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50)),
                                                    side: BorderSide(
                                                        color: greyScale)),
                                                onPressed: () {
                                                  camera();
                                                  Get.back();
                                                },
                                                child: Text(
                                                  "Camera".tr,
                                                  style: TextStyle(
                                                      fontFamily:
                                                          FontFamily.europaBold,
                                                      fontSize: 15,
                                                      color: notifire
                                                          .getwhiteblackcolor),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 15),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            height: 40,
                            width: 120,
                            margin: const EdgeInsets.symmetric(vertical: 13),
                            decoration: BoxDecoration(
                                border: Border.all(color: onbordingBlue),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              "Choose Files".tr,
                              style: TextStyle(
                                  color: onbordingBlue,
                                  fontFamily: FontFamily.europaBold),
                            )),
                          ),
                        ),
                        SingleChildScrollView(
                          clipBehavior: Clip.none,
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              netImg.isEmpty
                                  ? SizedBox()
                                  : SizedBox(
                                      height: 170,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.only(bottom: 10),
                                        itemCount: netImg.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                height: 300,
                                                width: 150,
                                                margin:
                                                    EdgeInsets.only(right: 15),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                            "${Config.imgUrl}${netImg[index]}"),
                                                        fit: BoxFit.cover)),
                                              ),
                                              Positioned(
                                                right: 5,
                                                top: -8,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      netImg.removeAt(index);
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 26,
                                                    width: 26,
                                                    decoration: BoxDecoration(
                                                      color: onbordingBlue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Center(
                                                        child: Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 18,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                              image.isEmpty
                                  ? SizedBox()
                                  : SizedBox(
                                      height: 170,
                                      child: ListView.builder(
                                        clipBehavior: Clip.none,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        padding: EdgeInsets.only(bottom: 10),
                                        itemCount: image.length,
                                        itemBuilder: (context, index) {
                                          return Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Container(
                                                height: 300,
                                                width: 150,
                                                margin:
                                                    EdgeInsets.only(right: 15),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    image: DecorationImage(
                                                        image: FileImage(
                                                            File(image[index])),
                                                        fit: BoxFit.cover)),
                                              ),
                                              Positioned(
                                                right: 5,
                                                top: -8,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    print(
                                                        "index removing image");
                                                    setState(() {
                                                      image.removeAt(index);
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 26,
                                                    width: 26,
                                                    decoration: BoxDecoration(
                                                      color: onbordingBlue,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Center(
                                                        child: Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 18,
                                                    )),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                            ],
                          ),
                        ),
                        isvalidate1
                            ? Text('Please Upload a Image.'.tr,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13))
                            : SizedBox(),

                        Text('Car AC?'.tr,
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: status.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    // ac = status[index];
                                    setState(() {
                                      selectIndex = index;
                                      ac = index == 0 ? '1' : '0';
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 18),
                                    margin: EdgeInsets.only(
                                        right: 10, top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                        color: ac == (index == 0 ? '1' : '0')
                                            ? onbordingBlue
                                            : Colors.transparent,
                                        border:
                                            Border.all(color: onbordingBlue),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text(status[index],
                                            style: TextStyle(
                                                color: ac ==
                                                        (index == 0 ? '1' : '0')
                                                    ? Colors.white
                                                    : onbordingBlue,
                                                fontFamily:
                                                    FontFamily.europaBold,
                                                fontSize: 15))),
                                  ),
                                );
                              }),
                        ),
                        isvalidate2
                            ? Text('Please Choose a AC.'.tr,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13))
                            : SizedBox(),
                        textfield(
                            title: 'Driver Name'.tr,
                            enterName: 'Enter Driver Name'.tr,
                            controller: driverController,
                            validate: 'Enter Driver Name'.tr),
                        textfield(
                            prefix: Icon(Icons.call_outlined,
                                color: notifire.getgreycolor),
                            title: 'Driver Mobile'.tr,
                            enterName: 'Enter Mobile Number'.tr,
                            controller: mobileController,
                            validate: 'Enter Mobile Number'.tr,
                            textInputType: TextInputType.number),

                        Row(
                          children: [
                            // Expanded(
                            //   child: Transform.translate(
                            //     offset: Offset(0, -6),
                            //     child: Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         Text('Car Rating'.tr,
                            //             style: TextStyle(
                            //                 color: notifire.getwhiteblackcolor,
                            //                 fontFamily: FontFamily.europaBold,
                            //                 fontSize: 15)),
                            //         const SizedBox(height: 10),
                            //         TextFormField(
                            //           maxLength: 1,
                            //           style: TextStyle(
                            //               fontFamily: FontFamily.europaBold,
                            //               color: notifire.getwhiteblackcolor),
                            //           controller: ratingController,
                            //           keyboardType: TextInputType.number,
                            //           inputFormatters: [
                            //             FilteringTextInputFormatter.deny(
                            //                 RegExp(r'[6,7,8,9,0,.,, ,-]'))
                            //           ],
                            //           validator: (value) {
                            //             if (value == null || value.isEmpty) {
                            //               return 'Enter Car Rating'.tr;
                            //             }
                            //             return null;
                            //           },
                            //           decoration: InputDecoration(
                            //             counterText: "",
                            //             contentPadding: EdgeInsets.all(8),
                            //             enabledBorder: OutlineInputBorder(
                            //                 borderSide: BorderSide(
                            //                     color: notifire.getborderColor),
                            //                 borderRadius:
                            //                     BorderRadius.circular(10)),
                            //             disabledBorder: OutlineInputBorder(
                            //                 borderSide: BorderSide(
                            //                     color: notifire.getborderColor),
                            //                 borderRadius:
                            //                     BorderRadius.circular(10)),
                            //             focusedBorder: OutlineInputBorder(
                            //                 borderSide:
                            //                     BorderSide(color: onbordingBlue),
                            //                 borderRadius:
                            //                     BorderRadius.circular(10)),
                            //             errorBorder: OutlineInputBorder(
                            //                 borderSide:
                            //                     BorderSide(color: onbordingBlue),
                            //                 borderRadius:
                            //                     BorderRadius.circular(10)),
                            //             focusedErrorBorder: OutlineInputBorder(
                            //                 borderSide:
                            //                     BorderSide(color: onbordingBlue),
                            //                 borderRadius:
                            //                     BorderRadius.circular(10)),
                            //             hintText: 'Enter Car Rating'.tr,
                            //             hintStyle: TextStyle(
                            //                 color: notifire.getgreycolor,
                            //                 fontSize: 13),
                            //           ),
                            //         ),
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            // SizedBox(width: 10),
                            Expanded(
                                child: textfield(
                                    title: 'Total Seat'.tr,
                                    enterName: 'Enter Total Seat'.tr,
                                    textInputType: TextInputType.number,
                                    controller: seatController,
                                    validate: 'Enter Total Seat'.tr)),
                          ],
                        ),

                        Text('Car Gear System?'.tr,
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        SizedBox(
                          height: 60,
                          child: ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: carGear.length,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    // gear = carGear[index];
                                    setState(() {
                                      gear = index == 0 ? '1' : '0';
                                      print(gear = index == 0 ? '1' : '0');
                                    });
                                  },
                                  child: Container(
                                    height: 50,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    margin: EdgeInsets.only(
                                        right: 10, top: 10, bottom: 10),
                                    decoration: BoxDecoration(
                                        color: gear == (index == 0 ? '1' : '0')
                                            ? onbordingBlue
                                            : Colors.transparent,
                                        border:
                                            Border.all(color: onbordingBlue),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text(carGear[index],
                                            style: TextStyle(
                                                color: gear ==
                                                        (index == 0 ? '1' : '0')
                                                    ? Colors.white
                                                    : onbordingBlue,
                                                fontFamily:
                                                    FontFamily.europaBold,
                                                fontSize: 15))),
                                  ),
                                );
                              }),
                        ),
                        isvalidate3
                            ? Text('Please select a Gear.'.tr,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13))
                            : SizedBox(),

                        Text('Car Facility'.tr,
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        loading
                            ? SizedBox()
                            : SizedBox(
                                height: 70,
                                child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        facilitylistModal.facilitylist.length,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          print(facilitylistModal
                                              .facilitylist[index].id);
                                          setState(() {
                                            if (multiSelect.contains(
                                                facilitylistModal
                                                    .facilitylist[index].id)) {
                                              setState(() {
                                                multiSelect.remove(
                                                    facilitylistModal
                                                        .facilitylist[index]
                                                        .id);
                                                print(multiSelect);
                                              });
                                            } else {
                                              setState(() {
                                                multiSelect.add(
                                                    facilitylistModal
                                                        .facilitylist[index]
                                                        .id);
                                              });
                                            }
                                          });
                                        },
                                        child: Container(
                                          height: 50,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          margin: EdgeInsets.only(
                                              right: 10, top: 10, bottom: 10),
                                          decoration: BoxDecoration(
                                              color: multiSelect.contains(
                                                      facilitylistModal
                                                          .facilitylist[index]
                                                          .id)
                                                  ? onbordingBlue
                                                  : Colors.transparent,
                                              border: Border.all(
                                                  color: onbordingBlue),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 7,
                                                        horizontal: 5),
                                                child: Image.network(
                                                    '${Config.imgUrl}${facilitylistModal.facilitylist[index].img}'),
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                  facilitylistModal!
                                                      .facilitylist[index]
                                                      .title,
                                                  style: TextStyle(
                                                      color: multiSelect.contains(
                                                              facilitylistModal
                                                                  .facilitylist[
                                                                      index]
                                                                  .id)
                                                          ? Colors.white
                                                          : onbordingBlue,
                                                      fontFamily:
                                                          FontFamily.europaBold,
                                                      fontSize: 15)),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                              ),
                        isvalidate4
                            ? Text('Please select a Facility.'.tr,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13))
                            : SizedBox(),

                        Text('Car Type?'.tr,
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        loading
                            ? SizedBox()
                            : SizedBox(
                                height: 65,
                                width: Get.size.width,
                                child: ListView.builder(
                                  itemCount: cType?.cartypelist.length,
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        // carType = banner.cartypelist[index].id;
                                        setState(() {
                                          selectType = index;
                                          carType =
                                              cType?.cartypelist[index].id;
                                        });
                                      },
                                      child: Container(
                                        height: 55,
                                        margin: EdgeInsets.only(
                                            top: 8, bottom: 8, right: 8),
                                        alignment: Alignment.center,
                                        padding: EdgeInsets.only(
                                            left: 10, right: 15),
                                        decoration: BoxDecoration(
                                          color: carType ==
                                                  cType?.cartypelist[index].id
                                              ? onbordingBlue
                                              : Colors.transparent,
                                          border:
                                              Border.all(color: onbordingBlue),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Image.network(
                                                "${Config.imgUrl}${cType?.cartypelist[index].img}",
                                                height: 30),
                                            SizedBox(width: 8),
                                            Text(
                                                cType!.cartypelist[index].title,
                                                style: TextStyle(
                                                    fontFamily:
                                                        FontFamily.europaBold,
                                                    fontSize: 15,
                                                    color: carType ==
                                                            cType
                                                                ?.cartypelist[
                                                                    index]
                                                                .id
                                                        ? Colors.white
                                                        : onbordingBlue)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        isvalidate5
                            ? Text('Please select a Car Type.'.tr,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13))
                            : SizedBox(),
                        Text('Car Brand?'.tr,
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        loading
                            ? SizedBox()
                            : SizedBox(
                                height: 120,
                                width: Get.size.width,
                                child: ListView.builder(
                                  itemCount: cBrand?.carbrandlist.length,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      onTap: () {
                                        // carBrand = banner.carbrandlist[index].id;
                                        setState(() {
                                          selectBrand = index;
                                          carBrand =
                                              cBrand?.carbrandlist[index].id;
                                        });
                                      },
                                      child: Container(
                                        height: 120,
                                        width: index == 4 ? 110 : 93,
                                        margin: EdgeInsets.only(
                                            top: 8, bottom: 8, right: 8),
                                        decoration: BoxDecoration(
                                          color: carBrand ==
                                                  cBrand?.carbrandlist[index].id
                                              ? onbordingBlue
                                              : Colors.transparent,
                                          border:
                                              Border.all(color: onbordingBlue),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.network(
                                                "${Config.imgUrl}${cBrand?.carbrandlist[index].img}",
                                                height: 40),
                                            SizedBox(height: 10),
                                            Text(
                                              cBrand!.carbrandlist[index].title,
                                              style: TextStyle(
                                                fontFamily:
                                                    FontFamily.europaBold,
                                                color: carBrand ==
                                                        cBrand
                                                            ?.carbrandlist[
                                                                index]
                                                            .id
                                                    ? Colors.white
                                                    : onbordingBlue,
                                                fontSize: 15,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                        isvalidate6
                            ? Text('Please select a Car Brand.'.tr,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13))
                            : SizedBox(),

                        Text('Available Car City?'.tr,
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        SizedBox(height: 13),

                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.4),
                                  width: 1),
                              borderRadius: BorderRadius.circular(8)),
                          height: 42.5,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedValue,
                                hint: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Select Your City',
                                        style: const TextStyle(
                                            color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue = newValue;
                                    dropId = cityDataList[newValue]!;
                                    print(dropId);
                                  });
                                },
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.grey.withOpacity(
                                      0.4), // Change this to the desired color
                                ),
                                items: cityDataList.keys
                                    .map<DropdownMenuItem<String>>(
                                        (String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        value,
                                        style: TextStyle(
                                          color: notifire.getwhiteblackcolor,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 10),
                        textfield(
                            title: 'Car Rent Price(Without Driver)'.tr,
                            enterName: 'Car Rent Price(Without Driver)'.tr,
                            textInputType: TextInputType.number,
                            controller: withoutRent,
                            validate: 'Enter Rent Price(Without Driver)'.tr),
                        // textfield(title: 'Car Rent Price(With Driver)'.tr,enterName: 'Car Rent Price(With Driver)'.tr,textInputType: TextInputType.number,controller: withRent, validate: 'Enter Rent Price(With Driver)'.tr),

                        Row(
                          children: [
                            // Expanded(child: textfield(title: 'Car Engine Hp'.tr,enterName: 'Enter Car Engine Hp'.tr, controller: engineController, validate: 'Enter Car Engine Hp'.tr, textInputType: TextInputType.number)),
                            //SizedBox(width: 10),
                            Expanded(
                                child: textfield(
                                    title: 'Minimum Hours'.tr,
                                    enterName: 'Enter Minimum Hours'.tr,
                                    controller: minimumController,
                                    validate: 'Enter Minimum Hours'.tr,
                                    textInputType: TextInputType.number)),
                          ],
                        ),
                        Text("Unavailable Dates",
                            style: TextStyle(
                                fontFamily: FontFamily.europaBold,
                                color: notifire.getwhiteblackcolor,
                                fontSize: 15)),
                        Wrap(
                          alignment: WrapAlignment.center,
                          children: <Widget>[
                            _buildMultiDatePickerWithValue(),
                          ],
                        ), // Container(

                        Text('Car Fuel Type?'.tr,
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        SizedBox(
                          height: 60,
                          width: Get.size.width,
                          child: ListView.builder(
                            itemCount: fuel.length,
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.zero,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  // carFuel = fuel[index];
                                  setState(() {
                                    fType = index;
                                    carFuel = index.toString();
                                    print(
                                        '- -- -- ---  ${fuel[index]} == $carFuel');
                                  });
                                },
                                child: Container(
                                  height: 60,
                                  margin: EdgeInsets.only(
                                      top: 8, bottom: 8, right: 8),
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: carFuel == index.toString()
                                        ? onbordingBlue
                                        : Colors.transparent,
                                    border: Border.all(color: onbordingBlue),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                      child: Text(
                                    fuel[index],
                                    style: TextStyle(
                                      fontFamily: FontFamily.europaBold,
                                      color: carFuel == index.toString()
                                          ? Colors.white
                                          : onbordingBlue,
                                      fontSize: 15,
                                    ),
                                  )),
                                ),
                              );
                            },
                          ),
                        ),
                        isvalidate8
                            ? Text('Please select a Fuel Type.'.tr,
                                style:
                                    TextStyle(color: Colors.red, fontSize: 13))
                            : SizedBox(),
                        Text('Car Location?',
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontFamily: FontFamily.europaBold,
                                fontSize: 15)),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                            'Select your general location of the car by moving and tapping on the map',
                            style: TextStyle(
                                color: notifire.getwhiteblackcolor,
                                fontSize: 13)),

                        Container(
                          height: 200,
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: GoogleMap(
                              minMaxZoomPreference:
                                  MinMaxZoomPreference.unbounded,
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                    () => EagerGestureRecognizer())
                              },
                              markers: markers,
                              initialCameraPosition: button == true
                                  ? CameraPosition(
                                      target: LatLng(
                                          double.parse(_currentPosition!
                                              .latitude
                                              .toString()),
                                          double.parse(_currentPosition!
                                              .longitude
                                              .toString())),
                                      zoom: 13)
                                  : CameraPosition(
                                      target: LatLng(
                                          double.parse(
                                              latController.text.toString()),
                                          double.parse(
                                              lngController.text.toString())),
                                      zoom: 13),
                              mapType: MapType.normal,
                              myLocationEnabled: false,
                              tiltGesturesEnabled: true,
                              onTap: (argument) {
                                latController.text =
                                    argument.latitude.toString();
                                lngController.text =
                                    argument.longitude.toString();
                                lats = argument.latitude;
                                lng = argument.longitude;
                                setState(() {
                                  markers.add(Marker(
                                    markerId: const MarkerId("1"),
                                    position: LatLng(
                                        double.parse(latController.text),
                                        double.parse(lngController.text)),
                                    icon: markerIcon,
                                  ));
                                });
                                print('LAT ${latController.text}');
                                print('LONG ${lngController.text}');
                              },
                              onMapCreated: (controller) {
                                setState(() {
                                  mapController = controller;
                                });
                              },
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                                child: textfield1(
                                    title: 'Car Latitude'.tr,
                                    textColor: notifire.getwhiteblackcolor,
                                    color: notifire.getwhiteblackcolor,
                                    enterName:
                                        '${lats ?? _currentPosition!.latitude}',
                                    fillcolor: notifire.getborderColor,
                                    controller: latController)),
                            SizedBox(width: 10),
                            Expanded(
                                child: textfield1(
                                    title: 'Car Longitude'.tr,
                                    textColor: notifire.getwhiteblackcolor,
                                    color: notifire.getwhiteblackcolor,
                                    enterName:
                                        '${lng ?? _currentPosition!.longitude}',
                                    fillcolor: notifire.getborderColor,
                                    controller: lngController)),
                          ],
                        ),
                        textfield(
                            title: 'Car Total Driven Km'.tr,
                            enterName: 'Enter Car Total Driven Km'.tr,
                            textInputType: TextInputType.number,
                            controller: totalKmController,
                            validate: 'Enter Car Total Driven Km'.tr),

                        textarea(
                            title: 'Car Description'.tr,
                            textColor: notifire.getwhiteblackcolor,
                            colors: notifire.getwhiteblackcolor,
                            enterName:
                                '''Replace this Example with your Cars Description by marketing your car to Potential Renters.
            
            Rent it for its ample space, ease of driving, and premium comfort that makes every journey enjoyable. 
            ''',
                            color: notifire.getborderColor,
                            controller: descController,
                            validator: 'Enter Car Description'.tr),
                        textarea(
                            title: 'Car Pickup Address'.tr,
                            textColor: notifire.getwhiteblackcolor,
                            colors: notifire.getwhiteblackcolor,
                            enterName:
                                "Example: Preferably you can meet for pickup at 2 Carvo Lane Kingston 10, or at the Barbican Police Station for this Car. If those do not work for you, book and we will arrange what is safest and convenient for us.",
                            color: notifire.getborderColor,
                            controller: addressController,
                            validator: 'Enter Pickup Address'.tr),
                        SizedBox(height: 70),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  double? lats;
  double? lng;

  late GoogleMapController mapController;
  Set<Marker> markers = {};
  BitmapDescriptor markerIcon = BitmapDescriptor.defaultMarker;
  void addCustomIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(), Appcontent.mapPin)
        .then(
      (icon) {
        setState(() {
          markerIcon = icon;
        });
      },
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(
          msg: 'Location services are disabled. Please enable the services');
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(msg: 'Location permissions are denied');
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg:
              'Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }
    return true;
  }

  Position? _currentPosition;
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
        button == true
            ? markers.add(Marker(
                markerId: const MarkerId("1"),
                position: LatLng(
                    double.parse(_currentPosition!.latitude.toString()),
                    double.parse(_currentPosition!.longitude.toString())),
                icon: markerIcon,
              ))
            : markers.add(Marker(
                markerId: const MarkerId("1"),
                position: LatLng(double.parse(latController.text.toString()),
                    double.parse(lngController.text.toString())),
                icon: markerIcon,
              ));
        isLoading = false;
      });
    }).catchError((e) {
      debugPrint(e.toString());
    });
  }

  getTime(startTime, endTime) {
    bool result = false;
    int startTimeInt = (startTime.hour * 60 + startTime.minute) * 60;
    int EndTimeInt = (endTime.hour * 60 + endTime.minute) * 60;
    int dif = EndTimeInt - startTimeInt;

    if (EndTimeInt > startTimeInt) {
      result = true;
    } else {
      result = false;
    }
    return result;
  }

  Widget textfield(
      {Widget? prefix,
      required String title,
      required String enterName,
      TextEditingController? controller,
      TextInputType? textInputType,
      String? validate}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                color: notifire.getwhiteblackcolor,
                fontFamily: FontFamily.europaBold,
                fontSize: 15)),
        const SizedBox(height: 10),
        TextFormField(
          style: TextStyle(
              fontFamily: FontFamily.europaBold,
              color: notifire.getwhiteblackcolor),
          controller: controller,
          keyboardType: textInputType,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return validate;
            }
            return null;
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(8),
            prefixIcon: prefix,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: notifire.getborderColor),
                borderRadius: BorderRadius.circular(10)),
            disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: notifire.getborderColor),
                borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: onbordingBlue),
                borderRadius: BorderRadius.circular(10)),
            errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: onbordingBlue),
                borderRadius: BorderRadius.circular(10)),
            focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: onbordingBlue),
                borderRadius: BorderRadius.circular(10)),
            hintText: enterName,
            hintStyle: TextStyle(color: notifire.getgreycolor, fontSize: 13),
          ),
        ),
        const SizedBox(height: 13),
      ],
    );
  }
}

TextEditingController nameController = TextEditingController();
TextEditingController cNumberController = TextEditingController();
TextEditingController driverController = TextEditingController();
TextEditingController mobileController = TextEditingController();
//TextEditingController ratingController = TextEditingController();
TextEditingController seatController = TextEditingController();
TextEditingController locationController = TextEditingController();
TextEditingController withoutRent = TextEditingController();
TextEditingController withRent = TextEditingController();
TextEditingController engineController = TextEditingController();
TextEditingController latController = TextEditingController();
TextEditingController lngController = TextEditingController();
TextEditingController totalKmController = TextEditingController();
TextEditingController descController = TextEditingController();
TextEditingController addressController = TextEditingController();
TextEditingController minimumController = TextEditingController();
List<DateTime?> _multiDatePickerValueWithDefaultValue = [];

var carStatus;
List<String> image = [];
var ac;
var gear;
List multiSelect1 = [];
List multiSelect = [];
List netImg = [];
var carType;
var carBrand;
var carPrice;
var carFuel;
var locationName;
String ccode = "";

bool button = false;

edit(
    {required String carName,
    required String carNumber,
    required String status,
    required List uploadImage,
    required String AC,
    required String carGear,
    required String carFacility,
    required String type,
    required String brand,
    required String driverName,
    required String countryCode,
    required String mobile,
    required String rating,
    required String seat,
    required String location,
    required String without,
    required String withrent,
    required String engine,
    required String pType,
    required String fuel,
    required String lat,
    required String long,
    required String totalKm,
    required String desc,
    required String address,
    required String minimum,
    required String isApprove,
    List<DateTime?>? unavailableDates,
    String? rejectComment}) async {
  nameController.text = carName;
  cNumberController.text = carNumber;
  carStatus = status;
  print('Status -- >  $carStatus');
  print(unavailableDates);
  uploadImage = image;
  ac = AC;
  driverController.text = driverName;
  ccode = countryCode;
  mobileController.text = mobile;

  seatController.text = seat;
  gear = carGear;
  multiSelect = carFacility.toString().split(",");
  carType = type;
  carBrand = brand;
  dropId = location;
  print("dropid is $dropId");
  withoutRent.text = without;
  withRent.text = withrent;
  engineController.text = engine;
  carPrice = pType;
  carFuel = fuel;
  latController.text = lat;
  lngController.text = long;
  totalKmController.text = totalKm;
  descController.text = desc;
  addressController.text = address;
  minimumController.text = minimum;
  isApproveValue = isApprove;
  rejectCommentValue = rejectComment;
  _multiDatePickerValueWithDefaultValue = unavailableDates!;
}

TimeOfDay stringToTimeOfDay(String timeString) {
  final timeParts = timeString.split(":");
  final hour = int.parse(timeParts[0]);
  final minute = int.parse(timeParts[1]);

  return TimeOfDay(hour: hour, minute: minute);
}
