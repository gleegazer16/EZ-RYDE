import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_webservice/places.dart';
import 'package:green_taxi_mine/cycle/api.dart';
import 'package:green_taxi_mine/user_side/ride_confirmed_user.dart';
import 'package:green_taxi_mine/views/decision_screen/decission_screen.dart';
import 'package:green_taxi_mine/customer_side/my_profile.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../controller/auth_controller.dart';
import '../controller/polyline_handler.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'dart:ui' as ui;
import '../widgets/text_widget.dart';
import '../views/payment.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController number_of_riders = TextEditingController();
  String? selectedHostel;
  String? sourceSelectedHostel;
  bool searchingDrivers = false;

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
    'Hostel A': LatLng(30.351429043075775, 76.3648188475935), // Dummy coordinates
    'Hostel B': LatLng(30.351223608385325, 76.36373949935499), // Add your real coordinates later
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

  String? _mapStyle;

  AuthController authController = Get.find<AuthController>();

  late LatLng destination;
  late LatLng source;
  final Set<Polyline> _polyline = {};
  Set<Marker> markers = Set<Marker>();
  List<String> list = <String>[
    '**** **** **** 8789',
    '**** **** **** 8921',
    '**** **** **** 1233',
    '**** **** **** 4352'
  ];
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    authController.getUserInfo();
    polyList.clear();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    loadCustomMarker();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  //var _razorpay = Razorpay();

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Do something when payment succeeds
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Do something when payment fails
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet is selected
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear(); // Removes all listeners
  }

  String dropdownValue = '**** **** **** 8789';

  final CameraPosition _kThaparUniv = CameraPosition(
    target: LatLng(30.3564, 76.3647),
    zoom: 14.4746,
  );

  GoogleMapController? myMapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: GoogleMap(
                mapType: MapType.terrain,
                markers: markers,
                polylines: polyline,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  myMapController = controller;
                  myMapController!.setMapStyle(_mapStyle);
                },
                initialCameraPosition: _kThaparUniv,
              ),
            ),
            buildProfileTile(),
            // buildTextField(),
            buildTextFieldForDestination(),
            showSourceField ? buildTextFieldForSource() : Container(),
            buildCurrentLocationIcon(),
            // buildNotificationIcon(),
            // buildBottomSheet(),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(onPressed: (){
      //   buildRideConfirmationSheet();
      // }),
    );
  }

//upar wale naam and good morning ke liye
  Widget buildProfileTile() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Obx(() => authController.myUser.value.name == null
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Container(
        width: Get.width,
        height: Get.width * 0.5,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(color: Colors.white70),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: authController.myUser.value.image == null
                    ? DecorationImage(
                  image: AssetImage('assets/person.png'),
                  fit: BoxFit.fill,
                )
                    : null, // Set to null when using CachedNetworkImage
              ),
              child: authController.myUser.value.image == null
                  ? null // No need to use CachedNetworkImage if image is null
                  : CachedNetworkImage(
                imageUrl: authController.myUser.value.image!,
                imageBuilder: (context, imageProvider) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // placeholder: (context, url) => CircularProgressIndicator(),
                // errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(children: [
                    TextSpan(
                        text: 'Good Morning, ',
                        style:
                        TextStyle(color: Colors.black, fontSize: 14)),
                    TextSpan(
                        text: authController.myUser.value.name,
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
                Text(
                  "Where are you going?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )
              ],
            )
          ],
        ),
      )),
    );
  }

  TextEditingController destinationController = TextEditingController();
  TextEditingController sourceController = TextEditingController();

  bool showSourceField = false;

  Widget buildTextFieldForDestination() {
    return Positioned(
      top: 170,
      left: 20,
      right: 20,
      child: Container(
        width: Get.width,
        height: 50,
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 4,
              blurRadius: 10,
            ),
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: TextFormField(
          controller: destinationController,
          readOnly: true,
          onTap: () {
            buildDestinationSheet();
          },
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'Search for a destination',
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                Icons.search,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
  void buildDestinationSheet() {
    Get.bottomSheet(
      Container(
        width: Get.width,
        height: Get.height * 0.3,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              "Select Your Destination",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'fontMain3',
              ),
            ),
            
            const SizedBox(height: 20),
          
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20,), // Adjusted padding for a balanced look
              decoration: BoxDecoration(
                color: Colors.white, // White background for clean design
                borderRadius: BorderRadius.circular(20), // Increased border radius for smooth corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4), // Slightly stronger shadow for better depth
                    spreadRadius: 4,
                    blurRadius: 12,
                    offset: Offset(0, 4), // Shadow offset to add elevation effect
                  ),
                ],
                border: Border.all(color: Colors.blueAccent, width: 2), // Border with blue accent for focus
              ),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: InputBorder.none, // Remove underline
                  contentPadding: EdgeInsets.symmetric(vertical: 12), // Padding within the dropdown button
                ),
                value: selectedHostel,
                hint: Text(
                  'Select Hostel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600], // Hint color for a lighter tone
                  ),
                ),
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.blueAccent, // Blue accent for icon
                  size: 30,
                ),
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600, // Bold for selected item
                ),
                items: hostels.map((hostel) {
                  return DropdownMenuItem<String>(
                    value: hostel,
                    child: Text(
                      hostel,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87, // Color for dropdown items
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedHostel = value;

                    // Clear existing markers and polylines
                    markers.clear();
                    polyList.clear();

                    // Update destination
                    LatLng selectedCoordinates = hostelCoordinates[value]!;
                    destination = selectedCoordinates;

                    // Add marker for destination
                    markers.add(Marker(
                      markerId: MarkerId(value!),
                      infoWindow: InfoWindow(
                        title: 'Destination: $value',
                      ),
                      position: destination,
                      icon: BitmapDescriptor.fromBytes(markIcons),
                    ));

                    // Animate map camera to the new destination
                    myMapController!.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: destination, zoom: 14),
                    ));

                    // Update the destination text and handle source field display
                    destinationController.text = value;
                    showSourceField = true;
                  });
                  Get.back(); // Close the bottom sheet
                },
                dropdownColor: Colors.white, // Background color for the dropdown menu
                iconEnabledColor: Colors.blueAccent, // Color for the icon when enabled
              ),
            ),
          ),

          SizedBox(height: 30),
            InkWell(
              onTap: () async {
                Get.back();
                Prediction? p = await authController.showGoogleAutoComplete(context);

                String selectedPlace = p!.description!;

                destinationController.text = selectedPlace;

                //  // Clear existing markers and polylines
                markers.clear();
                polyList.clear();

                List<geoCoding.Location> locations = await geoCoding.locationFromAddress(selectedPlace);

                destination = LatLng(locations.first.latitude, locations.first.longitude);

                // Add new destination marker
                markers.add(Marker(
                  markerId: MarkerId(selectedPlace),
                  infoWindow: InfoWindow(
                    title: 'Destination: $selectedPlace',
                  ),
                  position: destination,
                  icon: BitmapDescriptor.fromBytes(markIcons),
                ));

                // Update map camera position
                myMapController!.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: destination, zoom: 14),
                ));

                setState(() {
                  showSourceField = true;
                });

              },
              child: Container(
                width: Get.width,
                height: 50,
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      spreadRadius: 4,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Search for Address",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void buildDestinationSheet() {
  //   Get.bottomSheet(Container(
  //     width: Get.width,
  //     height: Get.height * 0.3,
  //     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(8),
  //         topRight: Radius.circular(8),
  //       ),
  //       color: Colors.white,
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         const SizedBox(
  //           height: 10,
  //         ),
  //         Text(
  //           "Select Your Destination",
  //           style: TextStyle(
  //             color: Colors.black,
  //             fontSize: 20,
  //             fontWeight: FontWeight.bold,
  //             fontFamily: 'fontMain3',
  //           ),
  //         ),
  //         const SizedBox(
  //           height: 20,
  //         ),
  //         Center(
  //           child: Container(
  //             padding: EdgeInsets.symmetric(horizontal: 20),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(15),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.grey.withOpacity(0.3),
  //                   spreadRadius: 3,
  //                   blurRadius: 10,
  //                   offset: Offset(0, 3),
  //                 ),
  //               ],
  //             ),
  //             child: DropdownButtonFormField<String>(
  //               decoration: InputDecoration(
  //                 border: InputBorder.none,
  //               ),
  //               value: selectedHostel,
  //               hint: Text(
  //                 'Select Hostel',
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //               ),
  //               icon:
  //               Icon(Icons.arrow_drop_down, color: Colors.black, size: 30),
  //               style: TextStyle(color: Colors.black, fontSize: 18),
  //               items: hostels.map((hostel) {
  //                 return DropdownMenuItem<String>(
  //                   value: hostel,
  //                   child: Text(
  //                     hostel,
  //                     style:
  //                     TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
  //                   ),
  //                 );
  //               }).toList(),
  //               onChanged: (value) {
  //                 setState(() {
  //                   selectedHostel = value;
  //                 });
  //               },
  //               dropdownColor: Colors.white,
  //               iconEnabledColor: Colors.black,
  //             ),
  //           ),
  //         ),
  //         SizedBox(
  //           height: 30,
  //         ),
  //         InkWell(
  //           onTap: () async {
  //             Get.back();
  //             Prediction? p =
  //             await authController.showGoogleAutoComplete(context);
  //
  //             String selectedPlace = p!.description!;
  //
  //             destinationController.text = selectedPlace;
  //
  //             List<geoCoding.Location> locations =
  //             await geoCoding.locationFromAddress(selectedPlace);
  //
  //             destination =
  //                 LatLng(locations.first.latitude, locations.first.longitude);
  //
  //             markers.add(Marker(
  //               markerId: MarkerId(selectedPlace),
  //               infoWindow: InfoWindow(
  //                 title: 'Destination: $selectedPlace',
  //               ),
  //               position: destination,
  //               icon: BitmapDescriptor.fromBytes(markIcons),
  //             ));
  //
  //             myMapController!.animateCamera(CameraUpdate.newCameraPosition(
  //               CameraPosition(target: destination, zoom: 14),
  //             ));
  //
  //             setState(() {
  //               showSourceField = true;
  //             });
  //           },
  //           child: Container(
  //             width: Get.width,
  //             height: 50,
  //             padding: EdgeInsets.symmetric(horizontal: 10),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(15),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.04),
  //                   spreadRadius: 4,
  //                   blurRadius: 10,
  //                 ),
  //               ],
  //             ),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   "Search for Address",
  //                   style: TextStyle(
  //                     color: Colors.black,
  //                     fontSize: 12,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                   textAlign: TextAlign.start,
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   ));
  // }

  Widget buildTextFieldForSource() {
    return Positioned(
      top: 230,
      left: 20,
      right: 20,
      child: Container(
        width: Get.width,
        height: 50,
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 4,
                  blurRadius: 10)
            ],
            borderRadius: BorderRadius.circular(8)),
        child: TextFormField(
          controller: sourceController,
          readOnly: true,
          onTap: () async {
            buildSourceSheet();
          },
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: 'From:',
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                Icons.search,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget buildCurrentLocationIcon() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 8),
        child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.green,
            child: IconButton(
              onPressed: () {
                buildRideConfirmationSheet();
              },
              icon: Icon(
                Icons.my_location,
                color: Colors.white,
              ),
            )),
      ),
    );
  }

  // Widget buildNotificationIcon() {
  //   return Align(
  //     alignment: Alignment.bottomLeft,
  //     child: Padding(
  //       padding: const EdgeInsets.only(bottom: 30, left: 8),
  //       child: CircleAvatar(
  //         radius: 20,
  //         backgroundColor: Colors.white,
  //         child: Icon(
  //           Icons.notifications,
  //           color: Color(0xffC3CDD6),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget buildBottomSheet() {
  //   return Align(
  //     alignment: Alignment.bottomCenter,
  //     child: Container(
  //       width: Get.width * 0.8,
  //       height: 25,
  //       decoration: BoxDecoration(
  //           color: Colors.white,
  //           boxShadow: [
  //             BoxShadow(
  //                 color: Colors.black.withOpacity(0.05),
  //                 spreadRadius: 4,
  //                 blurRadius: 10)
  //           ],
  //           borderRadius: BorderRadius.only(
  //               topRight: Radius.circular(12), topLeft: Radius.circular(12))),
  //       child: Center(
  //         child: Container(
  //           width: Get.width * 0.6,
  //           height: 4,
  //           color: Colors.black45,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  buildDrawerItem(
      {required String title,
        required Function onPressed,
        Color color = Colors.black,
        double fontSize = 20,
        FontWeight fontWeight = FontWeight.w700,
        double height = 45,
        bool isVisible = false}) {
    return SizedBox(
      height: height,
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        // minVerticalPadding: 0,
        dense: true,
        onTap: () => onPressed(),
        title: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: fontSize, fontWeight: fontWeight, color: color),
            ),
            const SizedBox(
              width: 5,
            ),
            isVisible
                ? CircleAvatar(
              backgroundColor: AppColors.greenColor,
              radius: 15,
              child: Text(
                '1',
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            )
                : Container()
          ],
        ),
      ),
    );
  }



  late Uint8List markIcons;

  loadCustomMarker() async {
    markIcons = await loadAsset('assets/dest_marker.png', 100);
  }

  Future<Uint8List> loadAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void drawPolyline(String placeId) {
    _polyline.clear();
    _polyline.add(Polyline(
      polylineId: PolylineId(placeId),
      visible: true,
      points: [source, destination],
      color: AppColors.greenColor,
      width: 5,
    ));
  }


  void buildSourceSheet() {
    Get.bottomSheet(Container(
      width: Get.width,
      height: Get.height * 0.4,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Text(
            "Select Your Location",
            style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'fontMain3'),
          ),
          const SizedBox(
            height: 20,
          ),
      Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16,), // Padding around the dropdown
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.4),
                spreadRadius: 4,
                blurRadius: 12,
                offset: Offset(0, 4), // Slight elevation effect
              ),
            ],
            border: Border.all(color: Colors.blueAccent, width: 2), // Blue border for focus
          ),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              border: InputBorder.none, // No default underline border
              contentPadding: EdgeInsets.symmetric(vertical: 10), // Adjust padding within dropdown
            ),
            value: sourceSelectedHostel,
            hint: Text(
              'Select Hostel',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600], // Light hint color
              ),
            ),
            icon: Icon(Icons.arrow_drop_down, color: Colors.blueAccent, size: 28), // Icon customization
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600, // Font style for items
            ),
            items: hostels.map((hostel) {
              return DropdownMenuItem<String>(
                value: hostel,
                child: Text(
                  hostel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87, // Text color for dropdown items
                  ),
                ),
              );
            }).toList(),
            onChanged: (value) async {
              setState(() {
                sourceSelectedHostel = value;
                LatLng selectedCoordinates = hostelCoordinates[value]!;
                source = selectedCoordinates;
                sourceController.text = value!;

                // Clear previous marker if needed and add new one
                if (markers.length >= 2) {
                  markers.remove(markers.last);
                }
                markers.add(Marker(
                  markerId: MarkerId(sourceSelectedHostel!),
                  infoWindow: InfoWindow(
                    title: 'Source: $sourceSelectedHostel',
                  ),
                  position: source,
                ));
              });

              // Await asynchronous polyline generation and camera animation
              await getPolylines(source, destination);
              myMapController!.animateCamera(CameraUpdate.newCameraPosition(
                CameraPosition(target: source, zoom: 14),
              ));

              // Close the dropdown/bottom sheet
              Get.back();
              setState(() {
                buildRideConfirmationSheet();
              });
            },
            dropdownColor: Colors.white, // Background color of dropdown items
            iconEnabledColor: Colors.blueAccent, // Color for the dropdown icon
          ),
        ),
      ),


      const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              "Home",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'fontMain3',
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          InkWell(
            onTap: () async {
              Get.back();
              source = authController.myUser.value.homeAddress!;
              sourceController.text = authController.myUser.value.hAddress!.split(',')[0];

              if (markers.length >= 2) {
                markers.remove(markers.last);
              }
              markers.add(Marker(
                  markerId: MarkerId(authController.myUser.value.hAddress!),
                  infoWindow: InfoWindow(
                    title: 'Source: ${authController.myUser.value.hAddress!}',
                  ),
                  position: source));

              await getPolylines(source, destination);

              // drawPolyline(place);

              myMapController!.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: source, zoom: 14)));
              setState(() {});

              buildRideConfirmationSheet();
            },
            child: Container(
              width: Get.width,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        spreadRadius: 4,
                        blurRadius: 10)
                  ]),
              child: Row(
                children: [
                  Text(
                    authController.myUser.value.hAddress!.split(',').first,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          InkWell(
            onTap: () async {
              Get.back();
              Prediction? p =
              await authController.showGoogleAutoComplete(context);

              String place = p!.description!;

              sourceController.text = place;

              source = await authController.buildLatLngFromAddress(place);

              if (markers.length >= 2) {
                markers.remove(markers.last);
              }
              markers.add(Marker(
                  markerId: MarkerId(place),
                  infoWindow: InfoWindow(
                    title: 'Source: $place',
                  ),
                  position: source));

              await getPolylines(source, destination);

              // drawPolyline(place);

              myMapController!.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: source, zoom: 14)));
              setState(() {});
              buildRideConfirmationSheet();
            },
            child: Container(
              width: Get.width,
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        spreadRadius: 4,
                        blurRadius: 10)
                  ]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Search for Address",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }

  buildRideConfirmationSheet() {
    Get.bottomSheet(Container(
      width: Get.width,
      height: Get.height * 0.4,
      padding: EdgeInsets.only(left: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(12), topLeft: Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          Center(
            child: Container(
              width: Get.width * 0.2,
              height: 8,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8), color: Colors.grey),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          textWidget(
              text: 'Book your ride:',
              fontSize: 18,
              fontWeight: FontWeight.bold),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Container(
                height: 90,
                width: 170,
                child: StatefulBuilder(builder: (context, set) {
                  return ListView.builder(
                    itemBuilder: (ctx, i) {
                      return InkWell(
                          onTap: () {
                            set(() {
                              selectedRide = i;
                            });
                          },
                          child: buildDriverCard(
                              selectedRide == i,
                              'E-Riksha',
                              '\Rs 10/person',
                              '2 MIN',
                              'assets/img_1.png',
                              Color(0xff2DBB54)
                          )
                        // : buildDriverCard(selectedRide == i, 'Cycle', '\Rs 5.0', '1 MIN', 'assets/img_2.jpg', Color(0xff2DBB54)),
                      );
                    },
                    itemCount: 1,
                    scrollDirection: Axis.horizontal,
                  );
                }),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Container(
                  height: 50,
                  width: 100,
                  child: TextField(
                    controller: number_of_riders,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Riders',
                      labelStyle: TextStyle(
                        fontSize: 9,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Icon(
                          Icons.person,
                          color: AppColors.greenColor,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    style: TextStyle(fontSize: 17.0),
                    onChanged: (value) {
                      final numValue = int.tryParse(value);
                      if (numValue == null || numValue < 1 || numValue > 4) {
                        // Clear the invalid input
                        number_of_riders.clear();

                        // Show a Snackbar for invalid input
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(
                        //     content: Text('Please enter a number between 1 and 4.'),
                        //     duration: Duration(seconds: 2),
                        //     backgroundColor: Colors.red,
                        //   ),
                        // );
                      }
                    },
                  ),
                ),
              )

            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Divider(),
          ),
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Padding(
                    padding: const EdgeInsets.only(right: 30, top: 20),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: buildPaymentCardWidget()),
                          searchingDrivers
                              ? FutureBuilder(
                            future: Future.delayed(Duration(milliseconds: 500)), // Delay for 500ms
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                // While waiting for the delay, show a loading indicator or an empty widget
                                return SizedBox();
                              }

                              // After the delay, display the StreamBuilder
                              return StreamBuilder<QuerySnapshot>(
                                stream: APIs.listenConfirmedRides(auth.currentUser!.uid),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return SizedBox(); // Handle the waiting state of the StreamBuilder
                                  }

                                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                    return SizedBox(); // Handle errors and empty data
                                  }

                                  Map<String, dynamic> confirmed = snapshot.data!.docs[0].data() as Map<String, dynamic>;

                                  if (confirmed['confirmed'] == "true") {
                                    // Ensure the navigation happens after the current frame is fully built
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => RideConfirmedScreen(data: confirmed)),
                                      );
                                      setState(() {
                                        searchingDrivers = false;
                                      });
                                    });
                                  }

                                  return Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        margin: EdgeInsets.only(bottom: 20),
                                        decoration: BoxDecoration(
                                          color: Colors.yellowAccent,
                                          image: DecorationImage(
                                            image: AssetImage('assets/search.gif'),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'finding...',
                                        style: TextStyle(color: Colors.grey, fontSize: 10),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                          )
                              : MaterialButton(
                            onPressed: () async {

                                if (number_of_riders.text.isNotEmpty) {
                                  setState(() {
                                    searchingDrivers = true;
                                  });


                                  await APIs.instantRide(
                                    sourceController.text,
                                    source,
                                    destinationController.text,
                                    destination,
                                    number_of_riders.text,
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                    msg: 'Fill Riders Info',
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.TOP,
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white,
                                  );
                                }

                            },
                            child:  textWidget(
                              text: 'Confirm',
                              color: Colors.white,
                            ),
                            color: AppColors.blackColor,
                            shape: StadiumBorder(),
                          )

                        ]));
              })
        ],
      ),
    ));
  }

  int selectedRide = 0;



  buildDriverCard(bool selected, String vehicleType, String price, String time,
      String imagePath, Color color) {
    return Container(
      margin: EdgeInsets.only(right: 8, left: 8, top: 4, bottom: 4),
      height: 85,
      width: 165,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: selected
                ? color.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            offset: Offset(0, 5),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
        borderRadius: BorderRadius.circular(12),
        color: selected ? color : Colors.grey,
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, top: 10, bottom: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                textWidget(
                    text: vehicleType,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
                textWidget(
                    text: price,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                fontSize: 11),
                textWidget(
                    text: time,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.normal,
                    fontSize: 12),
              ],
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Image.asset(imagePath),
          ),
        ],
      ),
    );
  }

  buildPaymentCardWidget() {
    return Column(
      children: [
        SizedBox(
          width: 60,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Container(
              child: Align(
                alignment: Alignment.centerLeft,
                child: MaterialButton(
                  onPressed: () {
                    // Add the logic for cash payment option here
                  },
                  color: AppColors.greenColor,
                  shape: const StadiumBorder(),
                  padding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //  const Icon(Icons.attach_money, color: Colors.white), // Add a cash/money icon
                      const SizedBox(width: 8.0),
                      // Space between icon and text
                      textWidget(
                        text: 'CASH/UPI',
                        color: Colors.white,
                        fontSize: 18.0, // Optional: Adjust font size if needed
                        fontWeight:
                        FontWeight.bold, // Optional: Add bold text if preferred
                      ),
                    ],
                  ),
                ),
              )),
        ),

      ],
    );
  }
}
