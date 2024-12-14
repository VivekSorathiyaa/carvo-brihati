// To parse this JSON data, do
//
//     final bookRangeModal = bookRangeModalFromJson(jsonString);

import 'dart:convert';

UnavailableDatesModal bookRangeModalFromJson(String str) => UnavailableDatesModal.fromJson(json.decode(str));

String bookRangeModalToJson(UnavailableDatesModal data) => json.encode(data.toJson());

class UnavailableDatesModal {
  List<Bookeddate> bookeddate;
  String responseCode;
  String result;
  String responseMsg;

  UnavailableDatesModal({
    required this.bookeddate,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory UnavailableDatesModal.fromJson(Map<String, dynamic> json) => UnavailableDatesModal(
    bookeddate: List<Bookeddate>.from(json["bookeddate"].map((x) => Bookeddate.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "bookeddate": List<dynamic>.from(bookeddate.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class Bookeddate {
  DateTime pickupDate;
  DateTime returnDate;

  Bookeddate({
    required this.pickupDate,
    required this.returnDate,
  });

  factory Bookeddate.fromJson(Map<String, dynamic> json) => Bookeddate(
    pickupDate: DateTime.parse(json["pickup_date"]),
    returnDate: DateTime.parse(json["return_date"]),
  );

  Map<String, dynamic> toJson() => {
    "pickup_date": "${pickupDate.year.toString().padLeft(4, '0')}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}",
    "return_date": "${returnDate.year.toString().padLeft(4, '0')}-${returnDate.month.toString().padLeft(2, '0')}-${returnDate.day.toString().padLeft(2, '0')}",
  };
}
