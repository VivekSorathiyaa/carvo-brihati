// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, empty_catches
import 'dart:convert';
import 'package:carlink/screen/login_flow/login_screen.dart';
import 'package:carlink/screen/login_flow/otp1_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/Custom_widget.dart';
import 'package:carlink/utils/Dark_lightmode.dart';
import 'package:carlink/utils/fontfameli_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../utils/common.dart';
import '../../utils/config.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  late ColorNotifire notifire;
  getdarkmodepreviousstate() async {
    final prefs = await SharedPreferences.getInstance();
    bool? previusstate = prefs.getBool("setIsDark");
    if (previusstate == null) {
      notifire.setIsDark = false;
    } else {
      notifire.setIsDark = previusstate;
    }
  }

  TextEditingController emailController = TextEditingController();
  String ccode = "";

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getbgcolor,
      bottomNavigationBar: SizedBox(
        height: 135,
        width: Get.size.width,
        child: Column(
          children: [
            GestButton(
              height: 50,
              Width: Get.size.width,
              buttoncolor: onbordingBlue,
              buttontext: "Reset Password".tr,
              margin: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              style: TextStyle(
                fontFamily: FontFamily.europaBold,
                color: WhiteColor,
                fontSize: 15,
              ),
              onclick: () {
                if (emailController.text.isNotEmpty) {
                  resetPassword(emailController.text);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter your email.')),
                  );
                }
              },
            ),
            SizedBox(height: 10),
            NormalButton(
              height: 50,
              width: Get.size.width,
              margin: EdgeInsets.symmetric(vertical: 3, horizontal: 20),
              buttonText: "Return to Sign In".tr,
              style: TextStyle(
                fontFamily: FontFamily.europaBold,
                color: onbordingBlue,
                fontSize: 15,
              ),
              border: Border.all(color: onbordingBlue),
              onTap: () {
                Get.back();
              },
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(6),
                        child: Image.asset(
                          "assets/x.png",
                          color: notifire.getwhiteblackcolor,
                        ),
                      ),
                    ),
                    SizedBox(height: Get.size.height * 0.04),
                    Container(
                      height: 100,
                      width: Get.size.width,
                      alignment: Alignment.center,
                      child: Image.asset("assets/EmptyPassword.png"),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: Get.size.width,
                      alignment: Alignment.center,
                      child: Text(
                        "Can’t sign in?".tr,
                        style: TextStyle(
                          fontFamily: FontFamily.europaBold,
                          color: notifire.getwhiteblackcolor,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      width: Get.size.width,
                      alignment: Alignment.center,
                      child: Text(
                        'Enter the mobile number associated with your account, and RideNow will send you a OTP to your register mobile number'
                            .tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: FontFamily.europaWoff,
                          color: greyScale,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    SizedBox(height: Get.size.height * 0.035),
                    textFormFild(
                      notifire,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset("assets/mail.png",
                            height: 25, width: 25, color: greyColor),
                      ),
                      labelText: "Email".tr,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email'.tr;
                        }
                        return null;
                      },
                    ),
                  ],
                ),
                isLoading ? loader() : SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset email sent!')),
      );
      FirebaseAnalytics.instance.logEvent(
                name: "password_reset",
                parameters: {"email": emailController.text});
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send password reset email.')),
      );
    }
  }
}
