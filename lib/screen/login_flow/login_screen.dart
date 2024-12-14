// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, empty_catches
import 'dart:convert';

import 'package:carlink/controller/login_controller.dart';
import 'package:carlink/model/login_modal.dart';
import 'package:carlink/screen/bottombar/bottombar_screen.dart';
import 'package:carlink/screen/login_flow/resetpassword_screen.dart';
import 'package:carlink/screen/login_flow/signup_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/Custom_widget.dart';
import 'package:carlink/utils/Dark_lightmode.dart';
import 'package:carlink/utils/fontfameli_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/App_content.dart';
import '../../utils/config.dart';
import '../bottombar/carinfo_screeen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginController loginController = Get.find();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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

  resetNew() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLogin', true);
    prefs.setBool('bottomsheet', true);
  }

  @override
  void initState() {
    getdarkmodepreviousstate();
    super.initState();
  }

  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String ccode = "";
  final _auth = FirebaseAuth.instance;
  LoginData? loginData;
  Future login(email, password) async {
    Map body = {
      'email': email,
      'password': "********",
    };
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      if (userCredential.user != null) {
        print("user login");
        print(body);
        var response = await http.post(Uri.parse(Config.baseUrl + Config.login),
            body: jsonEncode(body),
            headers: {
              'Content-Type': 'application/json',
            });

        print(response.statusCode);
        print(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        var data = jsonDecode(response.body.toString());

        if (response.statusCode == 200) {
          if (data["Result"] == "true") {
            prefs.setString('Usertype', data["type"]);
            data["type"] == "USER"
                ? prefs.setString('UserLogin', jsonEncode(data["UserLogin"]))
                : prefs.setString('AdminLogin', jsonEncode(data["AdminLogin"]));
            setState(() {
              data["type"] == "USER"
                  ? loginData = loginDataFromJson(response.body)
                  : null;
            });
            return data;
          } else {
            return data;
          }
        } else {
          return data;
        }
      }
    } catch (e) {
      print("object");
      print(e);
    }
  }

  Future gestLogin() async {
    Map body = {
      'email': "carvo@carvo.com",
      'password': "********",
    };

    print("user login");
    print(body);
    var response = await http.post(Uri.parse(Config.baseUrl + Config.login),
        body: jsonEncode(body),
        headers: {
          'Content-Type': 'application/json',
        });

    print(response.statusCode);
    print(response.body);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var data = jsonDecode(response.body.toString());

    if (response.statusCode == 200) {
      if (data["Result"] == "true") {
        prefs.setString('Usertype', data["type"]);
        data["type"] == "USER"
            ? prefs.setString('UserLogin', jsonEncode(data["UserLogin"]))
            : prefs.setString('AdminLogin', jsonEncode(data["AdminLogin"]));
        setState(() {
          data["type"] == "USER"
              ? loginData = loginDataFromJson(response.body)
              : null;
        });
        return data;
      } else {
        return data;
      }
    } else {
      return data;
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: notifire.getbgcolor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Get.back();
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      alignment: Alignment.center,
                      padding: EdgeInsets.all(6),
                      child: Image.asset(Appcontent.close,
                          color: notifire.getwhiteblackcolor),
                    ),
                  ),
                  SizedBox(height: Get.size.height * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sign in to carlink".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.europaBold,
                            color: notifire.getwhiteblackcolor,
                            fontSize: 28,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "Welcome back! Please enter your details.".tr,
                          style: TextStyle(
                            fontFamily: FontFamily.europaWoff,
                            fontSize: 15,
                            color: greyScale,
                          ),
                        ),
                        SizedBox(height: Get.size.height * 0.04),
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
                        SizedBox(height: 15),
                        GetBuilder<LoginController>(builder: (context) {
                          return textFormFild(
                            notifire,
                            controller: passwordController,
                            obscureText: loginController.showPassword,
                            suffixIcon: InkWell(
                              onTap: () {
                                loginController.showOfPassword();
                              },
                              child: !loginController.showPassword
                                  ? Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset("assets/eye.png",
                                          height: 25,
                                          width: 25,
                                          color: greyColor),
                                    )
                                  : Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Image.asset("assets/eye-off.png",
                                          height: 25,
                                          width: 25,
                                          color: greyColor),
                                    ),
                            ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset("assets/lock.png",
                                  height: 25, width: 25, color: greyColor),
                            ),
                            labelText: "Password".tr,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password'.tr;
                              }
                              return null;
                            },
                          );
                        }),
                        SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Get.to(ResetPasswordScreen());
                          },
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                    text: 'Forgot password? '.tr,
                                    style: TextStyle(
                                        fontFamily: FontFamily.europaWoff,
                                        color: notifire.getwhiteblackcolor,
                                        fontSize: 15)),
                                TextSpan(
                                    text: 'Reset it'.tr,
                                    style: TextStyle(
                                        fontFamily: FontFamily.europaBold,
                                        color: onbordingBlue,
                                        fontSize: 15)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Get.size.height * 0.03),
                        GestButton(
                          height: 50,
                          Width: Get.size.width,
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          buttoncolor: onbordingBlue,
                          buttontext: "Sign In".tr,
                          style: TextStyle(
                              color: WhiteColor,
                              fontFamily: FontFamily.europaBold,
                              fontSize: 15),
                          onclick: () {
                            if (emailController.text.isNotEmpty &&
                                passwordController.text.isNotEmpty) {
                              if (_formKey.currentState?.validate() ?? false) {
                                login(emailController.text,
                                        passwordController.text)
                                    .then((value) async {
                                  if (value["ResponseCode"] == "200") {
                                    Fluttertoast.showToast(
                                        msg: value['ResponseMsg']);

                                    resetNew();
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();
                                    String user = pref.getString("Usertype")!;

                                    if (user == "ADMIN") {
                                      OneSignal.User.addTagWithKey(
                                          "user_id", '0');
                                      Get.offAll(CarInfoScreen());
                                    } else {
                                      OneSignal.User.addTagWithKey(
                                          "user_id", loginData?.userLogin.id);
                                      Get.offAll(BottomBarScreen());
                                    }
                                    FirebaseAnalytics.instance.logEvent(
                                        name: "user_login",
                                        parameters: {
                                          "email": emailController.text,
                                        });
                                  } else {
                                    Fluttertoast.showToast(
                                        msg: value['ResponseMsg']);
                                  }
                                });
                              }
                            } else {
                              Fluttertoast.showToast(
                                  msg: 'Please some your text');
                            }
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 10,
                            ),
                            Text("Don’t have and account?".tr,
                                style: TextStyle(
                                    fontFamily: FontFamily.europaWoff,
                                    color: notifire.getwhiteblackcolor,
                                    fontSize: 15)),
                            SizedBox(width: 5),
                            TextButton(
                              onPressed: () {
                                Get.to(SignUpScreen());
                              },
                              child: Text("Sign Up".tr,
                                  style: TextStyle(
                                      fontFamily: FontFamily.europaBold,
                                      color: onbordingBlue,
                                      fontSize: 15)),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              gestLogin().then((value) async {
                                if (value["ResponseCode"] == "200") {
                                  Fluttertoast.showToast(
                                      msg: "Login as Guest User");

                                  resetNew();
                                  SharedPreferences pref =
                                      await SharedPreferences.getInstance();
                                  String user = pref.getString("Usertype")!;

                                  if (user == "ADMIN") {
                                    OneSignal.User.addTagWithKey(
                                        "user_id", '0');
                                    Get.offAll(CarInfoScreen());
                                  } else {
                                    OneSignal.User.addTagWithKey(
                                        "user_id", loginData?.userLogin.id);
                                    Get.offAll(BottomBarScreen());
                                  }
                                  FirebaseAnalytics.instance
                                      .logEvent(name: "guest_user");
                                } else {
                                  Fluttertoast.showToast(
                                      msg: value['ResponseMsg']);
                                }
                              });
                            },
                            child: Text("Enter as Guest",
                                style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    fontFamily: FontFamily.europaBold,
                                    color: onbordingBlue,
                                    fontSize: 15)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
