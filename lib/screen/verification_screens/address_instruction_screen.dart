import 'dart:io';

import 'package:carlink/screen/verification_screens/address_upload_screen.dart';
import 'package:carlink/screen/verification_screens/identity_upload_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/Dark_lightmode.dart';
import 'package:carlink/utils/config.dart';
import 'package:carlink/utils/fontfameli_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AdressInstructionsScreen extends StatefulWidget {
  const AdressInstructionsScreen({super.key});

  @override
  State<AdressInstructionsScreen> createState() =>
      _AdressInstructionsScreenState();
}

class _AdressInstructionsScreenState extends State<AdressInstructionsScreen> {
  late ColorNotifire notifire;
  bool isChecked = false;
  @override
  Widget build(BuildContext context) {
    notifire = Provider.of(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: onbordingBlue,
          elevation: 0,
          centerTitle: true,
          title: Text("Proof of Address",
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
                'To verify your address, please upload a clear image of your address document. Follow these steps to ensure your submission is accepted:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              InstructionItem(
                boldText: 'Ensure the entire document is visible: ',
                regularText:
                    'The document (e.g., utility bill, bank statement, or government letter) should fit within the camera frame, with no edges cut off.',
              ),
              InstructionItem(
                boldText: 'Ensure your address details are readable: ',
                regularText:
                    'Make sure your name, address, and any relevant dates are clearly visible and not blurry.',
              ),
              InstructionItem(
                boldText: 'Place the document on a flat surface: ',
                regularText:
                    'Avoid holding the document in your hand to prevent shaky or unclear images. Placing it on a table helps capture a sharp image.',
              ),
              InstructionItem(
                boldText: 'Avoid glare and shadows: ',
                regularText:
                    'Make sure there is enough light to capture the document clearly without any shadows or reflections.',
              ),
              InstructionItem(
                boldText: 'No additional objects in the photo: ',
                regularText:
                    'Ensure only the address document is in the frame to avoid confusion during the verification process.',
              ),
              InstructionItem(
                boldText: 'Document must be recent: ',
                regularText:
                    'Ensure the document is dated within the last three months for it to be accepted as valid proof of address.',
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
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    fixedSize: Size(Get.width, 50)),
                onPressed: () {
                  if (isChecked) {
                    Get.to(AddressUploadScreen());
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
        ));
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
