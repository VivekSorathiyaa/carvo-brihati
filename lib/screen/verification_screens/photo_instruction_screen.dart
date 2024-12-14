import 'package:carlink/screen/verification_screens/photo_upload_screen.dart';
import 'package:carlink/utils/Colors.dart';
import 'package:carlink/utils/Dark_lightmode.dart';
import 'package:carlink/utils/fontfameli_model.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

class PhotoInstructionsScreen extends StatefulWidget {
  const PhotoInstructionsScreen({super.key});

  @override
  State<PhotoInstructionsScreen> createState() =>
      _PhotoInstructionsScreenState();
}

class _PhotoInstructionsScreenState extends State<PhotoInstructionsScreen> {
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
            title: Text("Live Photo Verification",
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
                  'To verify your identity, please take a live photo of yourself. Follow these steps to ensure your submission is accepted:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                InstructionItem(
                  boldText: 'Ensure your face is fully visible: ',
                  regularText:
                      'Your entire face should be centered within the camera frame, with no part of your face cut off.',
                ),
                InstructionItem(
                  boldText: 'Find a well-lit area: ',
                  regularText:
                      'Make sure there is enough light to clearly capture your face without any shadows or overexposure.',
                ),
                InstructionItem(
                  boldText: 'Keep a neutral expression: ',
                  regularText:
                      'Avoid excessive facial expressions, hats, sunglasses, or other accessories that may obstruct your face.',
                ),
                InstructionItem(
                  boldText: 'Avoid glare and shadows: ',
                  regularText:
                      'Position the light source in front of you to prevent shadows on your face or glare on your glasses (if worn).',
                ),
                InstructionItem(
                  boldText: 'No additional people or objects in the photo: ',
                  regularText:
                      'Ensure only you are in the frame. No other people or items should be present in the background.',
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
                      Get.to(PhotoUploadScreen());
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
