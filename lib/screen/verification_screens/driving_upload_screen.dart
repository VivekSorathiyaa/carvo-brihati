import 'dart:convert';
import 'dart:io';

import 'package:carlink/screen/verification_screens/choose_doc_type_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/Dark_lightmode.dart';
import 'package:carlink/utils/common.dart';
import 'package:carlink/utils/config.dart';
import 'package:carlink/utils/fontfameli_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrivingUploadScreen extends StatefulWidget {
  const DrivingUploadScreen({super.key});

  @override
  State<DrivingUploadScreen> createState() => _DrivingUploadScreenState();
}

class _DrivingUploadScreenState extends State<DrivingUploadScreen> {
  late ColorNotifire notifire;
  XFile? selectImage;
  ImagePicker picker = ImagePicker();
  ImagePicker picker1 = ImagePicker();
  List<String> image = [];
  List multiSelect1 = [];
  List multiSelect = [];
  List netImg = [];
  bool isvalidate1 = false;
  var userData;

  @override
  void initState() {
    save();

    super.initState();
  }

  save() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userData = jsonDecode(prefs.getString('UserLogin') ?? '0');
    print(userData);
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

  bool _isLoading = false;
  Future addCar(uid, size) async {
    setState(() {
      _isLoading = true;
    });
    print(uid);
    print(size);
    print("add car");
    var headers = {'Cookie': 'PHPSESSID=36pnj5phm83llglrqid2qnuquk'};
    var request = http.MultipartRequest(
        'POST', Uri.parse('${Config.baseUrl}${Config.verifyDriving}'));
    print(request.fields);
    request.fields.addAll({
      'uid': uid,
      'size': size,
    });
    for (int a = 0; a < image.length; a++) {
      request.files
          .add(await http.MultipartFile.fromPath('cargallery$a', image[a]));
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    print(response.statusCode);

    if (response.statusCode == 200) {
      var data = jsonDecode(await response.stream.bytesToString());
      print(data);
      FirebaseAnalytics.instance
          .logEvent(name: "driving_proof_uploaded", parameters: {
        "userid": uid,
      });
      setState(() {
        _isLoading = false;
      });
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => ChooseDocumentTypeScreen()));
      return data;
    } else {
      var data = jsonDecode(await response.stream.bytesToString());
      print(data);
      setState(() {
        _isLoading = false;
      });
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of(context, listen: true);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: onbordingBlue,
            elevation: 0,
            centerTitle: true,
            title: Text("Upload Drivers License",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: FontFamily.europaBold,
                    fontSize: 18)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: _isLoading
                ? loader()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Please upload both sides of your Drivers License',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.center,
                          child: Image.asset(
                            "assets/driving.png",
                            height: 300,
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                                fontFamily:
                                                    FontFamily.europaBold,
                                                fontSize: 20,
                                                color: notifire
                                                    .getwhiteblackcolor),
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
                                                        fontFamily: FontFamily
                                                            .europaBold,
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
                                                        fontFamily: FontFamily
                                                            .europaBold,
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
                                "Upload Front",
                                style: TextStyle(
                                    color: onbordingBlue,
                                    fontFamily: FontFamily.europaBold),
                              )),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
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
                                                fontFamily:
                                                    FontFamily.europaBold,
                                                fontSize: 20,
                                                color: notifire
                                                    .getwhiteblackcolor),
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
                                                        fontFamily: FontFamily
                                                            .europaBold,
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
                                                        fontFamily: FontFamily
                                                            .europaBold,
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
                                "Upload Back",
                                style: TextStyle(
                                    color: onbordingBlue,
                                    fontFamily: FontFamily.europaBold),
                              )),
                            ),
                          ),
                        ],
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
                                                      BorderRadius.circular(10),
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
                                                      BorderRadius.circular(10),
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
                                                  print("index removing image");
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
                              style: TextStyle(color: Colors.red, fontSize: 13))
                          : SizedBox(),
                      Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            fixedSize: Size(Get.width, 50)),
                        onPressed: () {
                          if (!isvalidate1) {
                            addCar(userData['id'], image.length.toString());
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please some your text!!');
                          }
                        },
                        child: Text("Submit Photos",
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: FontFamily.europaBold)),
                      ),
                      SizedBox(height: 40)
                    ],
                  ),
          )),
    );
  }
}
