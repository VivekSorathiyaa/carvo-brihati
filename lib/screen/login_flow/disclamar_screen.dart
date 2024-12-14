import 'package:carlink/screen/login_flow/onbording_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/Custom_widget.dart';
import 'package:carlink/utils/fontfameli_model.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class DisclamarScreen extends StatefulWidget {
  const DisclamarScreen({super.key});

  @override
  State<DisclamarScreen> createState() => _DisclamarScreenState();
}

class _DisclamarScreenState extends State<DisclamarScreen> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  "Disclaimer",
                  style: TextStyle(
                    fontFamily: FontFamily.europaBold,
                    color: Colors.black,
                    fontSize: 28,
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                    "The information provided on this app is for general informational purposes only. While we strive to ensure the accuracy and reliability of the information, we make no representations or warranties of any kind, express or implied, about the completeness, accuracy, reliability, suitability, or availability of the vehicles or services provided through the app. Any reliance you place on such information is strictly at your own risk."),
                SizedBox(height: 16),
                Text(
                    "Regarding user identification, Carvo relies only on data provided. Therefore, all car owners are mandated to do their own checks. Carvo keeps records of data to support law enforcement and support a generally safe environment. Cases of fraud will be reported."),
                SizedBox(height: 16),
                Text(
                    "By using this app, you acknowledge and agree that Carvo is not liable for any direct, indirect, incidental, or consequential damages arising from your use of the app or from the booking, rental, or use of any vehicles offered through the app."),
                SizedBox(height: 16),
                Text(
                    "In the case of a person securing a rental from an owner - this party is responsible for verifying all rental terms, conditions, and insurance requirements with the rental provider before completing any transaction. The Carvo app may contain links to third-party websites, and we are not responsible for the content of such sites."),
                SizedBox(height: 16),
                Text(
                    "All bookings and rentals are subject to the terms and conditions of the rental agreement provided by Carvo. The user agrees to comply with all local traffic regulations and rental policies. Carvo reserves the right to deny service or cancel bookings at its discretion."),
                SizedBox(height: 16),
                Text(
                    "All users are expected to follow the trust, responsibility, and ethics terms on carvocarshare.com. Carvo reserves the right to terminate any user at any time."),
                SizedBox(height: 16),
                Text(
                    "By using Carvo, you acknowledge and agree that this app does not provide mediation services, nor does it act as an insurance company. Renters and vehicle owners are solely responsible for ensuring appropriate coverage and resolving any disputes. Carvo allows you to connect with top customers who provide verified credit card details. To ensure security, customers will be required to submit the following for verification: 1. Electricity bill or bank statement (showing address) 2.	Passport (if passport, provide TRN), or National ID 3.	Driver’s license, 4.	Live photo. Please note: You will not have access to the original files provided by customers for verification. However, we may share your NAME with other users."),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isChecked,
                      onChanged: (bool? value) {
                        setState(() {
                          isChecked = value!;
                        });
                      },
                    ),
                    Text('Accept Terms & Conditions'),
                  ],
                ),
                SizedBox(height: 40),
                GestButton(
                  height: 50,
                  Width: Get.size.width,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  buttoncolor: isChecked
                      ? onbordingBlue
                      : onbordingBlue.withOpacity(0.2),
                  buttontext: "Continue".tr,
                  style: TextStyle(
                      color: WhiteColor,
                      fontFamily: FontFamily.europaBold,
                      fontSize: 15),
                  onclick: () {
                    isChecked
                        ? onTapContinue()
                        : () {};
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onTapContinue(){
     print("1");
                            FirebaseAnalytics.instance.logEvent(
                              name: "terms_accepted",
                            );
                            print("2");
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const OnbordingScreen()),
                                (route) => false);
                            print("3");
  }
}
