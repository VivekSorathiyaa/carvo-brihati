// To parse this JSON data, do
//
//     final viewFeatureModal = viewFeatureModalFromJson(jsonString);

import 'dart:convert';

VerifyModal verifyModalFromJson(String str) =>
    VerifyModal.fromJson(json.decode(str));

String verifyModalToJson(VerifyModal data) => json.encode(data.toJson());

class VerifyModal {
  String responseCode;
  String result;
  String responseMsg;

  List<VerifyStatus> featureCar;

  VerifyModal({
    required this.responseCode,
    required this.result,
    required this.responseMsg,
    required this.featureCar,
  });

  factory VerifyModal.fromJson(Map<String, dynamic> json) => VerifyModal(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        featureCar: List<VerifyStatus>.from(
            json["myverifydata"].map((x) => VerifyStatus.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "myverifydata": List<dynamic>.from(featureCar.map((x) => x.toJson())),
      };
}

class VerifyStatus {
  String idStatus;
  String passportStatus;
  String drivingStatus;
  String photoStatus;
  String addressStatus;

  VerifyStatus({
    required this.idStatus,
    required this.passportStatus,
    required this.drivingStatus,
    required this.photoStatus,
    required this.addressStatus,
  });

  factory VerifyStatus.fromJson(Map<String, dynamic> json) => VerifyStatus(
        idStatus: json["id_card_status"],
        passportStatus: json["passport_status"],
        drivingStatus: json["driving_license_status"],
        photoStatus: json["live_photo_status"],
        addressStatus: json["address_status"],
      );

  Map<String, dynamic> toJson() => {
        "id_card_status": idStatus,
        "passport_status": passportStatus,
        "driving_license_status": drivingStatus,
        "live_photo_status": photoStatus,
        "address_status": addressStatus,
      };
}
