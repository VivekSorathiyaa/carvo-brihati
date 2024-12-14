import 'package:carlink/screen/verification_screens/identity_upload_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/Dark_lightmode.dart';
import 'package:carlink/utils/fontfameli_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class IdentityInstructionsScreen extends StatefulWidget {
  const IdentityInstructionsScreen({super.key});

  @override
  State<IdentityInstructionsScreen> createState() =>
      _IdentityInstructionsScreenState();
}

class _IdentityInstructionsScreenState
    extends State<IdentityInstructionsScreen> {
  late ColorNotifire notifire;
  bool isChecked = false;

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
            title: Text("Identity Verification",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: FontFamily.europaBold,
                    fontSize: 18)),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Text(
                  'To verify your identity, please upload a clear image of your ID card. Follow these steps to ensure your submission is accepted:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                InstructionItem(
                  boldText: 'Ensure the entire ID card is visible: ',
                  regularText:
                      'The ID card should fit within the camera frame, with no edges cut off.',
                ),
                InstructionItem(
                  boldText: 'Place your ID card on a flat surface: ',
                  regularText:
                      'Avoid holding the ID in your hand to prevent shaky or unclear images. Placing it on a table helps capture a sharp image.',
                ),
                InstructionItem(
                  boldText: 'Avoid glare and shadows: ',
                  regularText:
                      'Make sure there is enough light and no reflection on the ID card. Position the light source to avoid glare on laminated cards.',
                ),
                InstructionItem(
                  boldText: 'Capture the ID details clearly: ',
                  regularText:
                      'Ensure that the text on the ID (e.g., name, ID number) is readable and not blurry.',
                ),
                InstructionItem(
                  boldText: 'No additional objects in the photo: ',
                  regularText:
                      'Ensure only your ID card is in the frame to avoid confusion during the verification process.',
                ),
                Spacer(),
                CheckboxListTile(
                  title: Text(
                      "I confirm that I have reviewed and fully understand the above instructions."),
                  value: isChecked,
                  onChanged: (newValue) {
                    setState(() {
                      isChecked = newValue!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity
                      .leading, // Align checkbox to the left
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: onbordingBlue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      fixedSize: Size(Get.width, 50)),
                  onPressed: () {
                    if (isChecked) {
                      Get.to(IdentityUploadScreen());
                    } else {
                      Fluttertoast.showToast(
                          msg: 'Please confirm above instructions!');
                    }
                  },
                  child: Text("Upload Photos",
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

class InstructionItem extends StatelessWidget {
  final String boldText;
  final String regularText;

  InstructionItem({required this.boldText, required this.regularText});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, color: onbordingBlue),
          SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 14, color: Colors.black),
                children: [
                  TextSpan(
                    text: boldText,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: regularText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
