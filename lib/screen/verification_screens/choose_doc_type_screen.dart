import 'dart:convert';

import 'package:carlink/model/verify_model.dart';
import 'package:carlink/screen/bottombar/bottombar_screen.dart';
import 'package:carlink/screen/verification_screens/address_instruction_screen.dart';
import 'package:carlink/screen/verification_screens/driving_instruction_screen.dart';
import 'package:carlink/screen/verification_screens/identity_instructions_screen.dart';
import 'package:carlink/screen/verification_screens/passport_instructions_screen.dart';
import 'package:carlink/screen/verification_screens/photo_instruction_screen.dart';
import 'package:carlink/screen/verification_screens/verification_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/common.dart';
import 'package:carlink/utils/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChooseDocumentTypeScreen extends StatefulWidget {
  @override
  State<ChooseDocumentTypeScreen> createState() =>
      _ChooseDocumentTypeScreenState();
}

class _ChooseDocumentTypeScreenState extends State<ChooseDocumentTypeScreen> {
  @override
  void initState() {
    getvalidate();
    super.initState();
  }

  var id;
  Future getvalidate() async {
    print("get validate");
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    id = jsonDecode(sharedPreferences.getString('UserLogin')!);
    getUserStatus(id["id"]);
  }

  bool isLoading = true;
  int idStatus = 0;
  int passportStatus = 0;
  int drivingStatus = 0;
  int photoStatus = 0;
  int addressStatus = 0;
  VerifyModal? verifyStatus;
  Future getUserStatus(
    uid,
  ) async {
    setState(() {
      isLoading = true;
    });
    print("view feature");
    Map body = {
      "uid": uid,
    };
    print(body);
    print("***********");
    try {
      var response = await http.post(
          Uri.parse(Config.baseUrl + Config.verifyStatus),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(response.body);
        setState(() {
          verifyStatus = verifyModalFromJson(response.body);
          isLoading = false;
          print(verifyStatus!.featureCar.first.idStatus);
        });
      } else {
        print("error");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => VerificationScreen()));
          },
        ),
      ),
      body: isLoading
          ? loader()
          : Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose your document type",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Check and edit your personal information if needed.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  // DocumentTypeOption(
                  //   icon: Icons.account_circle,
                  //   label: "National ID (optional)",
                  //   status:verifyStatus!.featureCar.isEmpty?0: int.parse(verifyStatus!.featureCar.first.idStatus),
                  //   onTap: () {
                  //     Get.to(IdentityInstructionsScreen());
                  //   },
                  // ),
                  // SizedBox(height: 16),
                  DocumentTypeOption(
                    icon: Icons.public,
                    label: "Passport / National ID",
                    status:
                        verifyStatus!.featureCar.isEmpty
                            ? 0
                            : int.parse(
                                verifyStatus!.featureCar.first.passportStatus),
                    onTap: () {
                      Get.to(PassportInstructionsScreen());
                    },
                  ),
                  SizedBox(height: 16),
                  DocumentTypeOption(
                    icon: Icons.directions_car,
                    label: "Drivers license",
                    status:verifyStatus!.featureCar.isEmpty?0:
                        int.parse(verifyStatus!.featureCar.first.drivingStatus),
                    onTap: () {
                      Get.to(DrivingInstructionsScreen());
                    },
                  ),
                  SizedBox(height: 16),
                  DocumentTypeOption(
                    icon: Icons.image,
                    label: "Live Photo",
                    status: verifyStatus!.featureCar.isEmpty?0:
                        int.parse(verifyStatus!.featureCar.first.photoStatus),
                    onTap: () {
                      Get.to(PhotoInstructionsScreen());
                    },
                  ),
                  SizedBox(height: 16),
                  DocumentTypeOption(
                    icon: Icons.house,
                    label: "Proof of Address",
                    status: verifyStatus!.featureCar.isEmpty?0:
                        int.parse(verifyStatus!.featureCar.first.addressStatus),
                    onTap: () {
                      Get.to(AdressInstructionsScreen());
                    },
                  ),
                  Spacer(),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offAll(BottomBarScreen());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: onbordingBlue,
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Continue',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 40)
                ],
              ),
            ),
    );
  }
}

class DocumentTypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final int status;
  final Function onTap;

  const DocumentTypeOption({
    Key? key,
    required this.icon,
    required this.label,
    this.status = 1,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        status == 0
            ? onTap()
            : status == 2
                ? onTap()
                : () {
                    print("object");
                  };
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: onbordingBlue,
                  child: Icon(icon, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            status == 0
                ? Icon(Icons.arrow_forward_ios, color: onbordingBlue)
                : status == 1
                    ? Icon(Icons.pending_actions_sharp, color: onbordingBlue)
                    : status == 2
                        ? Icon(Icons.close, color: Colors.red)
                        : Icon(Icons.done, color: onbordingBlue),
          ],
        ),
      ),
    );
  }
}
