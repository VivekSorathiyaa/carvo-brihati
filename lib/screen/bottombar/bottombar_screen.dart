// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, avoid_print, prefer_typing_uninitialized_variables, unused_import
import 'dart:async';
import 'dart:convert';

import 'package:carlink/screen/bottombar/carinfo_screeen.dart';
import 'package:carlink/screen/bottombar/favorite_screen.dart';
import 'package:carlink/screen/bottombar/home_screen.dart';
import 'package:carlink/screen/bottombar/profile_screen.dart';
import 'package:carlink/screen/login_flow/login_screen.dart';
import 'package:carlink/screen/login_flow/signup_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/Dark_lightmode.dart';
import 'package:carlink/utils/config.dart';
import 'package:carlink/utils/fontfameli_model.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../controller/location_controller.dart';
import '../../model/homeData_modal.dart';
import '../../utils/App_content.dart';
import '../login_flow/onbording_screen.dart';
import 'explore_screen.dart';

class BottomBarScreen extends StatefulWidget {
  final String? userType;
  const BottomBarScreen({super.key, this.userType});

  @override
  State<BottomBarScreen> createState() => _BottomBarScreenState();
}

class _BottomBarScreenState extends State<BottomBarScreen> {
  int currentIndex = 0;
  List<Widget> myChilders = [
    HomeScreen(),
    ExploreScreen(),
    FavoriteScreen(),
    ProfileScreen(),
  ];

  List<Widget> ownerChilders = [
    CarInfoScreen(),
    ProfileScreen(),
  ];

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

  LocationController lController = Get.put(LocationController());
  locationSave() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    lName = _prefs.getString('location');
  }

  final DateRangePickerController _controller = DateRangePickerController();
  TextEditingController locationController = TextEditingController();

  late HomeBanner banner;
  bool load = true;
  bool isCarOwner = false;
  Future homeBanner(uid, dId) async {
    // List<Location> locations = await locationFromAddress(loName.toString());
    // double latitude = locations[0].latitude;
    // double longitude = locations[0].longitude;
    // print('Latitude --> $latitude Longitude --> $longitude');
    Map body = {
      "uid": uid,
      "lats": lat.toString(),
      "longs": long.toString(),
      "cityid": dId ?? 0,
    };
    try {
      var response = await http.post(
          Uri.parse(Config.baseUrl + Config.homeData),
          body: jsonEncode(body),
          headers: {
            'Content-Type': 'application/json',
          });
      if (response.statusCode == 200) {
        SharedPreferences shared = await SharedPreferences.getInstance();
        // shared.setString('lats', locations[0].latitude.toString());
        // shared.setString('longs', locations[0].longitude.toString());
        // shared.setString('lats', lat.toString());
        // shared.setString('longs', long.toString());
        setState(() {
          banner = homeBannerFromJson(response.body);
          load = false;
        });
      } else {}
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  bool? isLogin;

  var loId;
  var loName;
  var id;

  setLocal() async {
    SharedPreferences lName = await SharedPreferences.getInstance();
    id = jsonDecode(lName.getString('UserLogin')!);
    loName = lName.getString('locationName');
    loId = lName.getString('lId');
    homeBanner(id['id'], loId);
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

  @override
  void initState() {
    getdarkmodepreviousstate();
    setLocal();
    final DateTime today = DateTime.now();
    _controller.selectedRange =
        PickerDateRange(today, today.add(Duration(days: 3)));
    lController.dController = DateRangePickerController();
    getUserTypeFromLocal();
    getDataFromLocal().then((value) {
      if (isLogin!) {
        lController.cityList().then((value) {
          set();

          // lController.commonBottomSheet(context).then((value) {
          //   setLocal();
          //   homeBanner(id['id'], loId);
          //   locationSave();
          //   setState(() {});
          // });
        });
      } else {}
    });
    super.initState();
  }

  Future<void> _refresh() async {
    Future.delayed(
      const Duration(seconds: 1),
      () {
        setState(() {
          homeBanner(id['id'], loId);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return RefreshIndicator(
      onRefresh: _refresh,
      color: onbordingBlue,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: notifire.getbgcolor,
            // extendBody: true,
            // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            // floatingActionButton: isCarOwner
            //     ? load
            //         ? SizedBox()
            //         : banner.showAddCar == "0"
            //             ? SizedBox()
            //             : FloatingActionButton(
            //                 heroTag: null,
            //                 elevation: 0,
            //                 backgroundColor: onbordingBlue,
            //                 onPressed: () {

            //                 },
            //                 child: Icon(Icons.add, size: 30),
            //               )
            //     : null,
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: notifire.getbgcolor,
              type: BottomNavigationBarType.fixed,
              unselectedItemColor: greyScale1,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                  fontFamily: FontFamily.europaBold, fontSize: 12),
              fixedColor: onbordingBlue,
              unselectedLabelStyle:
                  const TextStyle(fontFamily: FontFamily.europaWoff),
              currentIndex: currentIndex,
              landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              items: isCarOwner
                  ? [
                      // Get.to(CarInfoScreen());
                      BottomNavigationBarItem(
                        icon: Image.asset("assets/homeBold.png",
                            color: greyScale1,
                            height: MediaQuery.of(context).size.height / 35),
                        activeIcon: Image.asset("assets/homeBold.png",
                            color: onbordingBlue,
                            height: MediaQuery.of(context).size.height / 35),
                        label: 'Home'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset("assets/profileBold.png",
                            color: greyScale1,
                            height: MediaQuery.of(context).size.height / 35),
                        activeIcon: Image.asset("assets/profileBold.png",
                            color: onbordingBlue,
                            height: MediaQuery.of(context).size.height / 35),
                        label: 'Profile'.tr,
                      ),
                    ]
                  : [
                      BottomNavigationBarItem(
                        icon: Image.asset("assets/homeBold.png",
                            color: greyScale1,
                            height: MediaQuery.of(context).size.height / 35),
                        activeIcon: Image.asset("assets/homeBold.png",
                            color: onbordingBlue,
                            height: MediaQuery.of(context).size.height / 35),
                        label: 'Home'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset("assets/location-pin.png",
                            height: MediaQuery.of(context).size.height / 35),
                        activeIcon: Image.asset("assets/location-pin.png",
                            color: onbordingBlue,
                            height: MediaQuery.of(context).size.height / 35),
                        label: 'Explore'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset("assets/fevoriteBold.png",
                            color: greyScale1,
                            height: MediaQuery.of(context).size.height / 35),
                        activeIcon: Image.asset("assets/fevoriteBold.png",
                            color: onbordingBlue,
                            height: MediaQuery.of(context).size.height / 35),
                        label: 'Favorites'.tr,
                      ),
                      BottomNavigationBarItem(
                        icon: Image.asset("assets/profileBold.png",
                            color: greyScale1,
                            height: MediaQuery.of(context).size.height / 35),
                        activeIcon: Image.asset("assets/profileBold.png",
                            color: onbordingBlue,
                            height: MediaQuery.of(context).size.height / 35),
                        label: 'Profile'.tr,
                      ),
                    ],
              onTap: (value) {
                setState(() {
                  print(id["id"]);
                  if (id["id"] == "0") {
                    if (value == 2) {
                      print("guest user");
                      showGuestUserPopup(context);
                    } else if (value == 3) {
                      print("guest user");
                      showGuestUserPopup(context);
                    } else {
                      currentIndex = value;
                    }
                  } else {
                    currentIndex = value;
                  }
                });
              },
            ),
            body: isCarOwner
                ? ownerChilders[currentIndex]
                : myChilders[currentIndex],
          ),
        ),
      ),
    );
  }

  Future getDataFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      print(prefs.getBool("bottomsheet"));
      isLogin = prefs.getBool("bottomsheet") ?? true;
      print(isLogin);
    });
  }

  Future getUserTypeFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      print(prefs.getBool("isCarOwner"));
      isCarOwner = prefs.getBool("isCarOwner") ?? false;
      print("car owner val $isCarOwner");
    });
  }

  Future set() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("bottomsheet", false);
  }
}
