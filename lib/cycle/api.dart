
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:green_taxi_mine/controller/auth_controller.dart';

class APIs {

  AuthController authController= Get.find<AuthController>();
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // to return current user
  static User get user => auth.currentUser!;

  //authcontroller

//get rent cards data
  static Stream<QuerySnapshot<Map<String, dynamic>>> getRentCycles() {
    return FirebaseFirestore.instance
        .collection('Rent')
       // .orderBy('time')
        .snapshots();
  }
//delete rent rides card
  static Future<void> deleteRent(String postId) async {
    await firestore
        .collection('Rent')
        .doc(postId)
        .delete();
  }
  // add instant ride details
  static Future<void> instantRide(
  String src_name,
  LatLng? srcLatLng,
  String dest_name,
  LatLng? destLatLng,
  String number_of_riders,
      ) async {
    AuthController authController = Get.find<AuthController>();
    Timestamp currentTimestamp = Timestamp.now();
    CollectionReference users = FirebaseFirestore.instance
        .collection('instant_rides');

    //String postId = users.doc().id;

    await users.doc(auth.currentUser!.uid).set({
      'src_name': src_name,
      'src_lat_lon': GeoPoint(srcLatLng!.latitude, srcLatLng.longitude),
      'dest_name': dest_name,
      'dest_lat_lon':GeoPoint(destLatLng!.latitude, destLatLng.longitude),
      'userId': auth.currentUser!.uid,
      'number_of_riders': number_of_riders,
      'confirmed': 'false',
      'driver_name': '',
      'driver_number': '',
      'driver_profile': '',
      'driver_id':'',
      'time': currentTimestamp,
      'user_name':authController.myUser.value.name!,
      'user_profile':authController.myUser.value.image!,
      'user_number':auth.currentUser!.phoneNumber,
    });
  }

// get instant rides
  static Stream<QuerySnapshot<Map<String, dynamic>>> getInstantRides() {
    return FirebaseFirestore.instance
        .collection('instant_rides')
        .orderBy('time',descending: true)
        .snapshots();
  }

  // for driver to update instant ride
  static Future<void> updateInstantRide(
      String postId,
      String driver_name,
      String driver_number,
      String driver_profile,
      ) async {
    CollectionReference users = FirebaseFirestore.instance
        .collection('instant_rides');
    await users.doc(postId).update({
      'confirmed': 'true',
      'driver_name': driver_name,
      'driver_number':driver_number ,
      'driver_profile':driver_profile ,
      'driver_id': auth.currentUser!.uid,
    });
  }

  //for auto ride history
  static Future<void> autoRideHistory(Map<String,dynamic>data,   String driver_name,
      String driver_number,
      String driver_profile,) async {
     final time = DateTime.now();
    CollectionReference users = FirebaseFirestore.instance
        .collection('auto_history');
    String postId = users.doc().id;
    await users.doc(postId).set({
      'src_name': data['src_name'],
      'dest_name': data['dest_name'],
      'number_of_riders':data['number_of_riders'],
      'driver_name': driver_name,
      'driver_number':driver_number ,
      'driver_profile':driver_profile ,
      'driver_id': auth.currentUser!.uid,
      'time': time,
      'user_name':data['user_name'],
      'user_profile':data['user_profile'],
      'user_number':data['user_number'],
      'user_id':data['userId'],
    });
  }
// get auto ride hisory
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAutoRideHistory() {
    return FirebaseFirestore.instance
        .collection('auto_history')
        .orderBy('time',descending: true)
        .snapshots();
  }


//listen confirmed in particular  instant ride
  static Stream<QuerySnapshot<Map<String, dynamic>>> listenConfirmedRides(String postId) {
    return FirebaseFirestore.instance
        .collection('instant_rides')
        .where('userId', isEqualTo: postId )
        .snapshots();
  }

//delete instant rides card
  static Future<void> deleteInstantRide(String postId) async {
    await firestore
        .collection('instant_rides')
        .doc(postId)
        .delete();
  }

  //cycle ride history
  static Future<void> cycleHistory(Map<String,dynamic>data) async {
    AuthController authController = Get.find<AuthController>();
    final time = DateTime.now();
    CollectionReference users = FirebaseFirestore.instance
        .collection('cycle_history');
    String postId = users.doc().id;
    await users.doc(postId).set({
      'cycle_name': data['name'],
      'cycle_profile': data['cycle'],
      'owner_name': data['owner_name'],
      'owner_profile':data['owner_profile'],
      'owner_address':data['owner_address_place'],
      'owner_number':data['owner_number'],
      'owner_id': data['uid'],
      'time': time,
      'lender_name':authController.myUser.value.name!,
      'lender_profile':authController.myUser.value.image!,
      'lender_address':authController.myUser.value.hAddress,
      'lender_number':auth.currentUser!.phoneNumber,
      'lender_id':auth.currentUser!.uid,
      'rate':data['rate'],
      'postId':postId,
    });
  }

  // get cycle ride hisory
  static Stream<QuerySnapshot<Map<String, dynamic>>> getCycleRideHistory() {
    return FirebaseFirestore.instance
        .collection('cycle_history')
        .orderBy('time',descending: true)
        .snapshots();
  }
  //delete cycle rides
  static Future<void> deleteCycle(
      String postId,) async {
    CollectionReference users = FirebaseFirestore.instance
        .collection('Rent');
    await users.doc(postId).delete();
  }

}
