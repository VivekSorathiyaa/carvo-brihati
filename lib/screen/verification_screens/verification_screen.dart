import 'package:carlink/screen/bottombar/bottombar_screen.dart';
import 'package:carlink/screen/verification_screens/choose_doc_type_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                Text(
                  'Verify your identity',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  'To make a withdrawal, your account must be verified by completing KYC verification, which involves providing proof of ID and residence documentation.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                Image.asset(
                  'assets/verify.png',
                  height: MediaQuery.of(context).size.height / 2,
                ),
                Spacer(),
                ElevatedButton(
                  onPressed: () {
                    Get.to(ChooseDocumentTypeScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: onbordingBlue,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Verify Identity',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.offAll(BottomBarScreen());
                  },
                  child: Text(
                    'Later',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
