import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverModel {
  List<String>? document;
  String? email;
  String? country;
  String? name;
  String? image;
  String? vehicle_color;
  String? vehicle_number;
  String? vehicle_type;
  String? vehicle_year;

  // LatLng? homeAddress;
  // LatLng? bussinessAddres;
  // LatLng? shoppingAddress;


  DriverModel({this.name,this.image,this.email,this.vehicle_number,this.vehicle_type});

  DriverModel.fromJson(Map<String,dynamic> json){
    document = (json['document'] != null) ? List<String>.from(json['document']) : null;
    email = json['email'];
    country = json['country'];
    name = json['name'];
    image = json['image'];
    vehicle_year = json['vehicle_year'];
    vehicle_color = json['vehicle_color'];
    vehicle_number = json['vehicle_number'];
    vehicle_type = json['vehicle_type'];
    // homeAddress = LatLng(json['home_latlng'].latitude, json['home_latlng'].longitude);
    // bussinessAddres = LatLng(json['business_latlng'].latitude, json['business_latlng'].longitude);
    // shoppingAddress = LatLng(json['shopping_latlng'].latitude, json['shopping_latlng'].longitude);
  }
}