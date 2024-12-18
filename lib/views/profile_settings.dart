import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:green_taxi_mine/controller/auth_controller.dart';
import 'package:green_taxi_mine/utils/app_colors.dart';
import 'package:green_taxi_mine/widgets/green_intro_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  TextEditingController nameController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthController authController = Get.find<AuthController>();

  final List<String> hostels = [
    'Hostel A',
    'Hostel B',
    'Hostel C',
    'Hostel D',
    'Hostel J',
    'Hostel O',
    'Hostel N',
    'Hostel Q',
    'Jaggi',
    'Cos',
    'Library',
    'B block',
    'C block',
    'F block',
    'Tan',
  ];

  final Map<String, LatLng> hostelCoordinates = {
    'Hostel A': LatLng(30.351429043075775, 76.3648188475935),
    'Hostel B': LatLng(30.351223608385325, 76.36373949935499),
    'Hostel C': LatLng(30.350970755821784, 76.36126754121192),
    'Hostel D': LatLng(30.350963810710144, 76.36033601708507),
    'Hostel J': LatLng(30.353138580821053, 76.36424953960413),
    'Hostel O': LatLng(30.35122915745811, 76.36242361130415),
    'Hostel N': LatLng(30.354871522370733, 76.36755642448996),
    'Hostel Q': LatLng(30.35192309133504, 76.36808878008151),
    'Jaggi': LatLng(30.35258517392027, 76.37120480336456),
    'Cos': LatLng(30.35439257186705, 76.36276051870801),
    'Library': LatLng(30.35443376519168, 76.37005016473813),
    'B block': LatLng(30.353137747943087, 76.37087923405129),
    'C block': LatLng(30.35372563793173, 76.37146874569295),
    'F block': LatLng(30.354245276295966, 76.37237023220045),
    'Tan': LatLng(30.35389173761733, 76.36924985679846),
  };

  File? selectedImage;
  final ImagePicker _picker = ImagePicker();

  String? selectedHome;
  String? selectedBusiness;
  String? selectedShop;

  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  greenIntroWidgetWithoutLogos(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        getImage(ImageSource.gallery);
                      },
                      child: selectedImage == null
                          ? Container(
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
                        height: 120,
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
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 23),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFieldWidget(
                        'Name', Icons.person_outlined, nameController, (String? input) {
                      if (input!.isEmpty) {
                        return 'Name is required!';
                      }
                      if (input.length < 5) {
                        return 'Please enter a valid name!';
                      }
                      return null;
                    }),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownWidget(
                      'Home Address',
                      Icons.home_outlined,
                      hostels,
                      selectedHome,
                          (String? newValue) {
                        setState(() {
                          selectedHome = newValue;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownWidget(
                      'Business Address',
                      Icons.card_travel,
                      hostels,
                      selectedBusiness,
                          (String? newValue) {
                        setState(() {
                          selectedBusiness = newValue;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DropdownWidget(
                      'Favourite Spot',
                      Icons.favorite,
                      hostels,
                      selectedShop,
                          (String? newValue) {
                        setState(() {
                          selectedShop = newValue;
                        });
                      },
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Obx(() => authController.isProfileUploading.value
                        ? Center(
                      child: CircularProgressIndicator(),
                    )
                        : greenButton('Submit', () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }

                      if (selectedImage == null) {
                        Get.snackbar('Warning', 'Please add your image');
                        return;
                      }

                      if (selectedHome == null ||
                          selectedBusiness == null ||
                          selectedShop == null) {
                        Get.snackbar('Warning', 'Please select all locations');
                        return;
                      }

                      authController.isProfileUploading(true);
                      authController.storeUserInfo(
                        selectedImage!,
                        nameController.text,
                        selectedHome!,
                        selectedBusiness!,
                        selectedShop!,
                        businessLatLng: hostelCoordinates[selectedBusiness]!,
                        homeLatLng: hostelCoordinates[selectedHome]!,
                        shoppingLatLng: hostelCoordinates[selectedShop]!,
                      );
                    })),
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
      String title, IconData iconData, TextEditingController controller, Function validator) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xffA7A7A7)),
        ),
        const SizedBox(
          height: 6,
        ),
        Container(
          width: Get.width,
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
            validator: (input) => validator(input),
            controller: controller,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xffA7A7A7)),
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
        ),
      ],
    );
  }

  DropdownWidget(String title, IconData iconData, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xffA7A7A7)),
        ),
        const SizedBox(
          height: 6,
        ),
        Container(
          width: Get.width,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 1)
              ],
              borderRadius: BorderRadius.circular(8)),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
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
            icon: const Icon(Icons.arrow_drop_down),
            onChanged: (String? newValue) {
              onChanged(newValue);
            },
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xffA7A7A7)
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget greenButton(String title, Function onPressed) {
    return MaterialButton(
      minWidth: Get.width,
      height: 50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      color: AppColors.greenColor,
      onPressed: () => onPressed(),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}


// take a look on google search for places thats why i am commenting out this below code


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_webservice/places.dart';
// import 'package:green_taxi_mine/controller/auth_controller.dart';
// import 'package:green_taxi_mine/utils/app_colors.dart';
// import 'package:green_taxi_mine/widgets/green_intro_widget.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart' as Path;
//
// class ProfileSettingScreen extends StatefulWidget {
//   const ProfileSettingScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
// }
//
// class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController homeController = TextEditingController();
//   TextEditingController businessController = TextEditingController();
//   TextEditingController shopController = TextEditingController();
//   GlobalKey<FormState> formKey = GlobalKey<FormState>();
//   AuthController authController = Get.find<AuthController>();
//
//
//   final List<String> hostels = [
//     'Hostel A',
//     'Hostel B',
//     'Hostel C',
//     'Hostel D',
//     'Hostel J',
//     'Hostel O',
//     'Hostel N',
//     'Hostel Q',
//     'Jaggi',
//     'Cos',
//     'Library',
//     'B block',
//     'C block',
//     'F block',
//     'Tan',
//   ];
//
//   final Map<String, LatLng> hostelCoordinates = {
//     'Hostel A': LatLng(30.351429043075775, 76.3648188475935), // Dummy coordinates
//     'Hostel B': LatLng(30.351223608385325, 76.36373949935499), // Add your real coordinates later
//     'Hostel C': LatLng(30.350970755821784, 76.36126754121192),
//     'Hostel D': LatLng(30.350963810710144, 76.36033601708507),
//     'Hostel J': LatLng(30.353138580821053, 76.36424953960413),
//     'Hostel O': LatLng(30.35122915745811, 76.36242361130415),
//     'Hostel N': LatLng(30.354871522370733, 76.36755642448996),
//     'Hostel Q': LatLng(30.35192309133504, 76.36808878008151),
//     'Jaggi': LatLng(30.35258517392027, 76.37120480336456),
//     'Cos': LatLng(30.35439257186705, 76.36276051870801),
//     'Library': LatLng(30.35443376519168, 76.37005016473813),
//     'B block': LatLng(30.353137747943087, 76.37087923405129),
//     'C block': LatLng(30.35372563793173, 76.37146874569295),
//     'F block': LatLng(30.354245276295966, 76.37237023220045),
//     'Tan': LatLng(30.35389173761733, 76.36924985679846),
//   };
//
//
//   final ImagePicker _picker = ImagePicker();
//   File? selectedImage;
//   late LatLng homeAddress;
//   late LatLng businessAddress;
//   late LatLng shoppingAddress;
//   getImage(ImageSource source) async {
//     final XFile? image = await _picker.pickImage(source: source);
//     if (image != null) {
//       selectedImage = File(image.path);
//       setState(() {});
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               height: Get.height * 0.4,
//               child: Stack(
//                 children: [
//                   greenIntroWidgetWithoutLogos(),
//                   Align(
//                     alignment: Alignment.bottomCenter,
//                     child: InkWell(
//                       onTap: () {
//                         getImage(ImageSource.gallery);
//                       },
//                       child: selectedImage == null
//                           ? Container(
//                         width: 120,
//                         height: 120,
//                         margin: EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Color(0xffD6D6D6)),
//                         child: Center(
//                           child: Icon(
//                             Icons.camera_alt_outlined,
//                             size: 40,
//                             color: Colors.white,
//                           ),
//                         ),
//                       )
//                           : Container(
//                         width: 120,
//                         height: 120,
//                         margin: EdgeInsets.only(bottom: 20),
//                         decoration: BoxDecoration(
//                             image: DecorationImage(
//                                 image: FileImage(selectedImage!),
//                                 fit: BoxFit.cover),
//                             shape: BoxShape.circle,
//                             color: Color(0xffD6D6D6)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 23),
//               child: Form(
//                 key: formKey,
//                 child: Column(
//                   children: [
//                     TextFieldWidget(
//                         'Name', Icons.person_outlined, nameController,(String? input){
//
//                       if(input!.isEmpty){
//                         return 'Name is required!';
//                       }
//
//                       if(input.length<5){
//                         return 'Please enter a valid name!';
//                       }
//
//                       return null;
//
//                     }),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     TextFieldWidget(
//                         'Home Address', Icons.home_outlined, homeController,(String? input){
//
//                       if(input!.isEmpty){
//                         return 'Home Address is required!';
//                       }
//
//                       return null;
//
//                     },
//                         onTap: ()async{
//
//                           Prediction? p = await  authController.showGoogleAutoComplete(context);
//
//                           /// now let's translate this selected address and convert it to latlng obj
//
//                           homeAddress = await authController.buildLatLngFromAddress(p!.description!);
//                           homeController.text = p.description!;
//                           ///store this information into firebase together once update is clicked
//                         },
//
//                         readOnly: true),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     TextFieldWidget('Business Address', Icons.card_travel,
//                         businessController,(String? input){
//                           if(input!.isEmpty){
//                             return 'Business Address is required!';
//                           }
//
//                           return null;
//                         },onTap: ()async{
//                           Prediction? p = await  authController.showGoogleAutoComplete(context);
//
//                           /// now let's translate this selected address and convert it to latlng obj
//
//                           businessAddress = await authController.buildLatLngFromAddress(p!.description!);
//                           businessController.text = p.description!;
//                           ///store this information into firebase together once update is clicked
//
//                         },readOnly: true),
//                     const SizedBox(
//                       height: 10,
//                     ),
//                     TextFieldWidget('Favourite Spot',
//                         Icons.favorite, shopController,(String? input){
//                           if(input!.isEmpty){
//                             return 'Favourite Spot is required!';
//                           }
//
//                           return null;
//                         },onTap: ()async{
//                           Prediction? p = await  authController.showGoogleAutoComplete(context);
//
//                           /// now let's translate this selected address and convert it to latlng obj
//
//                           shoppingAddress = await authController.buildLatLngFromAddress(p!.description!);
//                           shopController.text = p.description!;
//                           ///store this information into firebase together once update is clicked
//
//                         },readOnly: true),
//                     const SizedBox(
//                       height: 30,
//                     ),
//                     Obx(() => authController.isProfileUploading.value
//                         ? Center(
//                       child: CircularProgressIndicator(),
//                     )
//                         : greenButton('Submit', () {
//
//
//                       if(!formKey.currentState!.validate()){
//                         return;
//                       }
//
//                       if (selectedImage == null) {
//                         Get.snackbar('Warning', 'Please add your image');
//                         return;
//                       }
//                       authController.isProfileUploading(true);
//                       authController.storeUserInfo(
//                           selectedImage!,
//                           nameController.text,
//                           homeController.text,
//                           businessController.text,
//                           shopController.text,
//                           businessLatLng: businessAddress,
//                           homeLatLng: homeAddress,
//                           shoppingLatLng: shoppingAddress
//                       );
//                     })),
//                   ],
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   TextFieldWidget(
//       String title, IconData iconData, TextEditingController controller,Function validator,{Function? onTap,bool readOnly = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Color(0xffA7A7A7)),
//         ),
//         const SizedBox(
//           height: 6,
//         ),
//         Container(
//           width: Get.width,
//           // height: 50,
//           decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     spreadRadius: 1,
//                     blurRadius: 1)
//               ],
//               borderRadius: BorderRadius.circular(8)),
//           child: TextFormField(
//             readOnly: readOnly,
//             onTap: ()=> onTap!(),
//             validator: (input)=> validator(input),
//             controller: controller,
//             style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xffA7A7A7)),
//             decoration: InputDecoration(
//               prefixIcon: Padding(
//                 padding: const EdgeInsets.only(left: 10),
//                 child: Icon(
//                   iconData,
//                   color: AppColors.greenColor,
//                 ),
//               ),
//               border: InputBorder.none,
//             ),
//           ),
//         )
//       ],
//     );
//   }
//
//   Widget greenButton(String title, Function onPressed) {
//     return MaterialButton(
//       minWidth: Get.width,
//       height: 50,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//       color: AppColors.greenColor,
//       onPressed: () => onPressed(),
//       child: Text(
//         title,
//         style: GoogleFonts.poppins(
//             fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
//       ),
//     );
//   }
// }
