import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:green_taxi_mine/customer_side/customer_bottom_bar.dart';
import 'package:green_taxi_mine/cycle/api.dart';
import 'package:green_taxi_mine/driver_side/driver_bottom_bar.dart';
import 'package:green_taxi_mine/models/driver_model/driver_model.dart';
import 'package:green_taxi_mine/models/user_model/user_model.dart';
import 'package:green_taxi_mine/views/driver/car_registration/car_registration_template.dart';
import 'package:green_taxi_mine/customer_side/home.dart';
import 'package:green_taxi_mine/views/profile_settings.dart';
import 'package:path/path.dart' as Path;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../views/driver/profile_setup.dart';

class AuthController extends GetxController {
  String userUid = '';
  var verId = '';
  int? resendTokenId;
  bool phoneAuthCheck = false;
  dynamic credentials;

  var isProfileUploading = false.obs;

  bool isLoginAsDriver = false;

  Future<void> loadIsLoginAsDriver() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDriver = prefs.getBool('isLoginAsDriver');
    isLoginAsDriver = isDriver ?? false;  // Default to false if not set
    update();
  }



  storeUserCard(String number, String expiry, String cvv, String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cards')
        .add({'name': name, 'number': number, 'cvv': cvv, 'expiry': expiry});

    return true;
  }

  RxList userCards = [].obs;

  getUserCards() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid).collection('cards')
    .snapshots().listen((event) {
      userCards.value = event.docs;
    });
  }

  phoneAuth(String phone) async {
    try {
      credentials = null;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          log('Completed');
          credentials = credential;
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        forceResendingToken: resendTokenId,
        verificationFailed: (FirebaseAuthException e) {
          log('Failed');
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          log('Code sent');
          verId = verificationId;
          resendTokenId = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      log("Error occured $e");
    }
  }

  verifyOtp(String otpNumber) async {
    log("Called");
    PhoneAuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: otpNumber);

    log("LogedIn");

    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      decideRoute();
    }).catchError((e) {
      print("Error while sign In $e");
    });
  }

 // var isDecided = false;

  // Ensure that loadIsLoginAsDriver is called before deciding the route.
  Future<void> decideRoute() async {
    print("decideRoute called");

    // Wait for the login status to load
    await loadIsLoginAsDriver();

  //  User? user = FirebaseAuth.instance.currentUser;
    print("Thari maa ki chutt ${APIs.auth.currentUser!.uid}");
    if (APIs.auth.currentUser != null) {
      // Decide the route based on login status
      if (isLoginAsDriver) {
        FirebaseFirestore.instance
            .collection('drivers')
            .doc(APIs.auth.currentUser!.uid )
            .get()
            .then((value) {
          if (value.exists) {
            Get.offAll(() => DriverBottomBar());
            print("Driver Home Screen");
          } else {
            Get.offAll(() => DriverProfileSetup());
          }
        }).catchError((e) {
          print("Error while deciding route: $e");
        });
      } else {
        FirebaseFirestore.instance
            .collection('users')
            .doc(APIs.auth.currentUser!.uid )
            .get()
            .then((value) {
          if (value.exists) {
            Get.offAll(() => BottomBarCustomer());
          } else {
            Get.offAll(() => ProfileSettingScreen());
          }
        }).catchError((e) {
          print("Error while deciding route: $e");
        });
      }
    }
  }

  // Future<void> decideRoute() async {
  //   if (!isDecided) {
  //     isDecided = true;
  //     print("called");
  //
  //     // Wait for the login status to load
  //     await loadIsLoginAsDriver();
  //
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       // Decide the route based on login status
  //       if (isLoginAsDriver) {
  //         FirebaseFirestore.instance
  //             .collection('drivers')
  //             .doc(user.uid)
  //             .get()
  //             .then((value) {
  //           if (value.exists) {
  //             Get.offAll(() => DriverBottomBar());
  //             print("Driver Home Screen");
  //           } else {
  //             Get.offAll(() => DriverProfileSetup());
  //           }
  //         }).catchError((e) {
  //           print("Error while deciding route: $e");
  //         });
  //       } else {
  //         FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .get()
  //             .then((value) {
  //           if (value.exists) {
  //             Get.offAll(() => BottomBarCustomer());
  //           } else {
  //             Get.offAll(() => ProfileSettingScreen());
  //           }
  //         }).catchError((e) {
  //           print("Error while deciding route: $e");
  //         });
  //       }
  //     }
  //   }
  // }

  uploadImage(File image) async {
    String imageUrl = '';
    String fileName = Path.basename(image.path);
    var reference = FirebaseStorage.instance
        .ref()
        .child('users/$fileName'); // Modify this path/string as your need
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then(
      (value) {
        imageUrl = value;
        print("Download URL: $value");
      },
    );

    return imageUrl;
  }

  //for multiple images
  Future<List<String>> uploadMultipleImages(List<File> images) async {
    List<String> imageUrls = [];

    for (File image in images) {
      String fileName = Path.basename(image.path);
      var reference = FirebaseStorage.instance
          .ref()
          .child('users/$fileName'); // Modify this path as needed

      UploadTask uploadTask = reference.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);

      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);

      print("Download URL for $fileName: $imageUrl");
    }

    return imageUrls;
  }

  storeUserInfo(
    File? selectedImage,
    String name,
    String home,
    String business,
    String shop, {
    String url = '',
    LatLng? homeLatLng,
    LatLng? businessLatLng,
    LatLng? shoppingLatLng,
  }) async {
    String url_new = url;
    if (selectedImage != null) {
      url_new = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc(uid).set({
      'image': url_new,
      'name': name,
      'home_address': home,
      'business_address': business,
      'shopping_address': shop,
      'home_latlng': GeoPoint(homeLatLng!.latitude, homeLatLng.longitude),
      'business_latlng':
          GeoPoint(businessLatLng!.latitude, businessLatLng.longitude),
      'shopping_latlng':
          GeoPoint(shoppingLatLng!.latitude, shoppingLatLng.longitude),
    },SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      Get.to(() => BottomBarCustomer());
    });
  }

  storeDriverInfo(
      File? selectedImage,
      String name,
      String email,
      String vehicle_type,
      String vehicle_number,

      {
        String url = '',
        // LatLng? homeLatLng,
        // LatLng? businessLatLng,
        // LatLng? shoppingLatLng,
      }
      )
     async {
    String url_new = url;
    if (selectedImage != null) {
      url_new = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('drivers').doc(uid).set({
      'image': url_new,
      'name': name,
      'email': email,
      'vehicle_number': vehicle_number,
      'vehicle_type': vehicle_type,
      // 'home_latlng': GeoPoint(homeLatLng!.latitude, homeLatLng.longitude),
      // 'business_latlng':
      // GeoPoint(businessLatLng!.latitude, businessLatLng.longitude),
      // 'shopping_latlng':
      // GeoPoint(shoppingLatLng!.latitude, shoppingLatLng.longitude),
    },SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      Get.to(() =>DriverBottomBar());
    });
  }

  var myUser = UserModel().obs;

  getUserInfo() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((event) {
      myUser.value = UserModel.fromJson(event.data()!);
    });
  }

  var myDriver = DriverModel().obs;
  getDriverInfo() {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('drivers')
        .doc(uid)
        .snapshots()
        .listen((event) {
      myDriver.value = DriverModel.fromJson(event.data()!);
    });
  }

  Future<Prediction?> showGoogleAutoComplete(BuildContext context) async {
    Prediction? p = await PlacesAutocomplete.show(
      offset: 0,
      radius: 1000,
      strictbounds: false,
      region: "in",
      language: "en",
      context: context,
      mode: Mode.overlay,
      apiKey: AppConstants.kGoogleApiKey,
      components: [new Component(Component.country, "in")],
      types: [],
      hint: "Search City",
    );

    return p;
  }

  Future<LatLng> buildLatLngFromAddress(String place) async {
    List<geoCoding.Location> locations =
        await geoCoding.locationFromAddress(place);
    return LatLng(locations.first.latitude, locations.first.longitude);
  }



  storeDriverProfile(
      File? selectedImage,
      String name,
      String email, {
        String url = '',

      }) async {
    String url_new = url;
    if (selectedImage != null) {
      url_new = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('drivers').doc(uid).set({
      'image': url_new,
      'name': name,
      'email': email,
      'isDriver': true
    },SetOptions(merge: true)).then((value) {
      isProfileUploading(false);

      Get.off(()=> CarRegistrationTemplate());



    });
  }

  

  Future<bool> uploadCarEntry(Map<String,dynamic> carData)async{
     bool isUploaded = false;
    String uid = FirebaseAuth.instance.currentUser!.uid;

   await FirebaseFirestore.instance.collection('drivers').doc(uid).set(carData,SetOptions(merge: true));

   isUploaded = true;

    return isUploaded;
  }

}
