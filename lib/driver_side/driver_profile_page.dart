import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:green_taxi_mine/controller/auth_controller.dart';
import 'package:green_taxi_mine/utils/app_colors.dart';
import 'package:green_taxi_mine/customer_side/home.dart';
import 'package:green_taxi_mine/views/decision_screen/decission_screen.dart';
import 'package:green_taxi_mine/widgets/green_intro_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class DriverProfile extends StatefulWidget {
  const DriverProfile({Key? key}) : super(key: key);

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  TextEditingController nameController = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController vehicle_type = TextEditingController();
  TextEditingController vehicle_number = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthController authController = Get.find<AuthController>();

  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  getImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  //
  // late LatLng homeAddress;
  // late LatLng businessAddress;
  // late LatLng shoppingAddress;
  @override
  void initState() {
    super.initState();
    nameController.text = authController.myDriver.value.name??"";
    email.text = authController.myDriver.value.email??"";
    vehicle_number.text = authController.myDriver.value.vehicle_number??"";
    vehicle_type.text = authController.myDriver.value.vehicle_type??"";

    // homeAddress = authController.myUser.value.homeAddress!;
    // businessAddress = authController.myUser.value.bussinessAddres!;
    // shoppingAddress = authController.myUser.value.shoppingAddress!;

  }

  @override
  Widget build(BuildContext context) {
    print(authController.myDriver.value.image!);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: Get.height * 0.4,
              child: Stack(
                children: [
                  greenIntroWidgetWithoutLogos(title: 'My Profile'),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        getImage();
                      },
                      child: selectedImage == null
                          ? authController.myDriver.value.image!=null? Container(
                        width: 120,
                        height: 120,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100)),
                            child:ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: CachedNetworkImage(
                                  imageUrl: authController.myDriver.value.image!,
                                fit: BoxFit.cover,
                              ),
                            )
                      ): Container(
                        width: 120,
                        height: 120,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffD6D6D6)),
                        child: Center(
                          child: Icon(
                            Icons.camera_alt_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      )
                          : Container(
                        width: 120,
                        height: 100,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: FileImage(selectedImage!),
                                fit: BoxFit.cover),
                            shape: BoxShape.circle,
                            color: Color(0xffD6D6D6)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 0,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 23),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFieldWidget(
                      'Name', Icons.person_outlined, nameController,(String? input){
                      if(input!.isEmpty){
                        return 'Name is required!';
                      }
                      if(input.length<5){
                        return 'Please enter a valid name!';
                      }
                      return null;
                    },),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldWidget(
                        'Email', Icons.email, email,(String? input){
                      if(input!.isEmpty){
                        return 'Email is required!';
                      }
                      return null;

                    },),
                    //     onTap: ()async{
                    //   Prediction? p = await  authController.showGoogleAutoComplete(context);
                    //
                    //   /// now let's translate this selected address and convert it to latlng obj
                    //
                    //   homeAddress = await authController.buildLatLngFromAddress(p!.description!);
                    //   email.text = p.description!;
                    //   ///store this information into firebase together once update is clicked
                    //
                    //
                    //
                    // },readOnly: true
                    // ),

                    // SizedBox(
                    //   height: 10,
                    // ),
                    // TextFieldWidget('Vehicle Type', Icons.local_taxi_outlined,
                    //     vehicle_type,(String? input){
                    //       if(input!.isEmpty){
                    //         return 'Vehicle Type is required!';
                    //       }
                    //
                    //       return null;
                    //     },),
                  // onTap: ()async{
                  //         Prediction? p = await  authController.showGoogleAutoComplete(context);
                  //
                  //         /// now let's translate this selected address and convert it to latlng obj
                  //
                  //         businessAddress = await authController.buildLatLngFromAddress(p!.description!);
                  //         vehicle_type.text = p.description!;
                  //         ///store this information into firebase together once update is clicked
                  //
                  //       },readOnly: true),
                    const SizedBox(
                      height: 10,
                    ),
                    TextFieldWidget('Vehicle Number',
                        Icons.taxi_alert, vehicle_number,(String? input){
                          if(input!.isEmpty){
                            return 'Vehicle Number is required!';
                          }

                          return null;
                        },),
                  // onTap: ()async{
                  //         Prediction? p = await  authController.showGoogleAutoComplete(context);
                  //
                  //         /// now let's translate this selected address and convert it to latlng obj
                  //
                  //         shoppingAddress = await authController.buildLatLngFromAddress(p!.description!);
                  //         vehicle_number.text = p.description!;
                  //         ///store this information into firebase together once update is clicked
                  //
                  //       },readOnly: true),
                    const SizedBox(
                      height: 30,
                    ),
                    Obx(() => authController.isProfileUploading.value
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        : greenButton('Update', () {


                      if(!formKey.currentState!.validate()){
                        return;
                      }


                      authController.isProfileUploading(true);
                      authController.storeDriverInfo(
                          selectedImage,
                          nameController.text,
                          email.text,
                          vehicle_type.text,
                          vehicle_number.text,
                          url: authController.myDriver.value.image??"",
                          // homeLatLng: homeAddress,
                          // shoppingLatLng: shoppingAddress,
                          // businessLatLng: businessAddress
                      );
                    })),

                    Padding(
                      padding:  EdgeInsets.only(left: 25,top: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(onPressed: ()async{
                            await FirebaseAuth.instance.signOut();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DecisionScreen()),
                                  (Route<dynamic> route) =>
                              false, // This removes all previous routes
                            );
                          }, child: Row(
                            children: [
                              Text('Logout',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.black),),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(Icons.logout,color: Colors.grey[700],),
                            ],
                          )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  TextFieldWidget(
      String title, IconData iconData,
      TextEditingController controller,
      Function validator,
     //{Function? onTap, bool readOnly = false}
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xffA7A7A7)),
        ),
        const SizedBox(
          height: 6,
        ),
        Container(
          width: Get.width,
          // height: 50,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 1)
              ],
              borderRadius: BorderRadius.circular(8)),
          child: TextFormField(
            // readOnly: readOnly,
            // onTap: ()=> onTap!(),
            validator: (input)=> validator(input),
            controller: controller,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xffA7A7A7)),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  iconData,
                  color: AppColors.greenColor,
                ),
              ),
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Widget greenButton(String title, Function onPressed) {
    return Padding(
      padding:  EdgeInsets.only(left: 30.0,right: 30.0),
      child: MaterialButton(
        minWidth: Get.width,
        height: 50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        color: AppColors.greenColor,
        onPressed: () => onPressed(),
        child: Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
