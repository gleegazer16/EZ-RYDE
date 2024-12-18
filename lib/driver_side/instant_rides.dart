import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:green_taxi_mine/controller/auth_controller.dart';
import 'package:green_taxi_mine/cycle/api.dart';
import 'package:green_taxi_mine/cycle/booking_confirmed_page.dart';
import 'package:green_taxi_mine/cycle/cycle_card.dart';
import 'package:green_taxi_mine/driver_side/driver_bottom_bar.dart';
import 'package:green_taxi_mine/driver_side/driver_home_page.dart';

const Color fontMainColor = Color(0xff293038);
const Color fontSecondColor = Color(0xff696e74);
const Color bicycleAppColor = Color(0xffffc329);

class InstantRides extends StatefulWidget {
  const InstantRides({super.key});
  @override
  State<InstantRides> createState() => _InstantRidesState();
}

class _InstantRidesState extends State<InstantRides> {
  Position? position;
  late LatLng destination;
  late LatLng source;
  bool loading = true; // Flag to track if the location is being fetched
  AuthController authController = Get.find<AuthController>();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      position = await _determinePosition();
      if (position != null) {
        setState(() {
          source = LatLng(position!.latitude, position!.longitude);
          loading = false; // Location fetched successfully
        });
      }
    } catch (e) {
      // Handle exceptions (like permissions issues)
      print('Error fetching location: $e');
      setState(() {
        loading = false; // Stop loading even if location fetching fails
      });
    }
  }


  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low,);
  }


  String getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 5) {
      return 'Just now';
    } else if (difference.inSeconds < 60) {
      return '${difference.inSeconds} seconds ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return 'on ${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }


  double calculateDistanceBetweenAddresses(GeoPoint rentHomeGeoPoint, LatLng currentHomeLatLng) {
    // Extract latitude and longitude from GeoPoint and LatLng
    double rentHomeLatitude = rentHomeGeoPoint.latitude;
    double rentHomeLongitude = rentHomeGeoPoint.longitude;

    double currentHomeLatitude = currentHomeLatLng.latitude;
    double currentHomeLongitude = currentHomeLatLng.longitude;

    // Calculate the distance in meters
    double distanceInMeters = Geolocator.distanceBetween(
      rentHomeLatitude,
      rentHomeLongitude,
      currentHomeLatitude,
      currentHomeLongitude,
    );

    // Convert the distance to kilometers and return
    return distanceInMeters / 1000; // distance in kilometers
  }

  Future Sheet(Map<String, dynamic> cycle){
    return  showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Confirm Lending',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Are you sure you want to lend the ride?',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async{

                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => BookingConfirmedPage(cycle:cycle,)),
                        );
                        APIs.deleteRent(cycle['postId']);
                      },
                      child: Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body:loading?
      Center(child: CircularProgressIndicator(color: Colors.white,))
      :SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      left: 16,
                      top: 24,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text.rich(TextSpan(children: [
                              TextSpan(text: "Hit ", style: TextStyle(color: fontSecondColor, fontSize: 22)),
                              TextSpan(
                                  text: "Accept",
                                  style: TextStyle(color: fontMainColor, fontSize: 22, fontWeight: FontWeight.bold)),
                            ])),
                            Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: "Take the ",
                                  style: TextStyle(color: fontSecondColor, fontSize: 22, )),
                              TextSpan(text: "Road!", style: TextStyle(color: fontMainColor, fontSize: 22,fontWeight: FontWeight.bold)),
                            ])),

                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 0,
                      child: Container(
                          height: 140,
                          width: 170,
                          // decoration: BoxDecoration(
                          //     border: Border.all(color: bicycleAppColor), borderRadius: BorderRadius.circular(10)),
                          child: Container(
                            width: 120,
                            height: 20,
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              image: DecorationImage(
                                  image: AssetImage('assets/auto2.gif'),
                                  fit: BoxFit.cover),
                              //   shape: BoxShape.circle,
                              //   color: Color(0xffD6D6D6)
                            ),
                          )
                      ),
                    )
                  ],
                ),
              ),
              Container(
                height: 64,
                padding: EdgeInsets.only(left: 16),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            top: 0,
                            bottom: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: bicycleAppColor,
                            ),
                          ),
                          Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Text(
                                  "Newest",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Text(
                                  "Explorers",
                                  style: TextStyle(fontSize: 17,
                                      fontWeight: FontWeight
                                          .w300),
                                ),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: APIs.getInstantRides(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                    return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> rides = snapshot.data!.docs[index].data() as Map<String, dynamic>;

                        String srcName = rides['src_name'].split(',').first;
                        String destName = rides['dest_name'].split(',').first;
                        var GeoPoint = rides['src_lat_lon'];
                        destination = LatLng(GeoPoint.latitude, GeoPoint.longitude);

                        final dist = Geolocator.distanceBetween(source.latitude, source.longitude, destination.latitude, destination.longitude); // Placeholder for calculated distance

                        return Visibility(
                          visible: dist.toInt()<=500,
                          child: Card(
                            elevation: 6,
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Time and Number of Riders
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Time ago
                                      Text(
                                        getTimeAgo(rides['time'].toDate()), // Assuming rides['time'] is a Timestamp from Firestore
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),

                                      // Number of riders
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            color: Colors.green,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            '${rides['number_of_riders']} Riders',
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(color: Colors.grey[300]),

                                  // Source Address
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.redAccent),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              'Src:  ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '$srcName',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 8),

                                  // Destination Address
                                  Row(
                                    children: [
                                      Icon(Icons.flag, color: Colors.blueAccent),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Row(
                                          children: [
                                            Text(
                                              'Des:  ',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '$destName',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 12),

                                  // Distance
                                  Row(
                                    children: [
                                      Icon(Icons.directions, color: Colors.orangeAccent),
                                      SizedBox(width: 8),
                                      Text(
                                        'Dist: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${dist.toInt()} m',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 10),

                                  // Accept Button
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton.icon(
                                      onPressed: () async{
                                        // Handle accept action
                                        await APIs.updateInstantRide(rides['userId'], authController.myDriver.value.name!,auth.currentUser!.phoneNumber! , authController.myDriver.value.image!).then((value) async{
                                          //ride history
                                          await APIs.autoRideHistory(rides,authController.myDriver.value.name!,auth.currentUser!.phoneNumber! , authController.myDriver.value.image!).then((value) async{
                                            //now delete ride
                                          //
                                            Navigator.push(context, MaterialPageRoute(builder: (context)=>DriverHomeScreen(source: source,destination: destination,)));
                                          });
                                        });
                                        await APIs.deleteInstantRide(rides['userId']);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: StadiumBorder(),
                                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                      ),
                                      icon: Icon(Icons.check_circle_outline, color: Colors.white),
                                      label: Text(
                                        'Accept Ride',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 200),
                    child: Center(
                      child: Text(
                        'No Rides Available',
                        style: TextStyle(color: fontSecondColor, fontSize: 22),
                      ),
                    ),
                  );
                },
              )

            ],
          ),
        ),
      ),


    );
  }
}
//   Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     Container(
//       height: MediaQuery.of(context).size.height / 4,
//       padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//       child: SizedBox(
//         child: Card(
//           elevation: 5,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           color: Colors.white,
//           child: Column(
//             children: [
//               // Top section with image and details
//               Expanded(
//                 flex: 4,
//                 child: Stack(
//                   children: [
//                     Positioned(
//                       right: 8,
//                       top: 8,
//                       bottom: 0,
//                       child: Container(
//                         width: 140,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           image: DecorationImage(
//                             image: NetworkImage(rides['cycle']),
//                             fit: BoxFit.fitHeight,
//                           ),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       left: 16,
//                       top: 16,
//                       bottom: 8,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             rides['name'],
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               color: Colors.black,
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 7),
//                             child: Text(
//                               "Electric Bike",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: fontSecondColor,
//                               ),
//                             ),
//                           ),
//                           Spacer(),
//                           Text.rich(
//                             TextSpan(children: [
//                               TextSpan(
//                                 text: rides['rate'] + " \R\s\. ",
//                                 style: TextStyle(
//                                   color: bicycleAppColor,
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                               TextSpan(
//                                 text: " / hour",
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: fontSecondColor,
//                                 ),
//                               ),
//                             ]),
//                           ),
//                           Spacer(),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               // Bottom section with details and button
//               Expanded(
//                 flex: 2,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Distance",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: fontSecondColor,
//                               ),
//                             ),
//                             Text(
//                               dist.toStringAsFixed(2) + " Km",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Speed",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: fontSecondColor,
//                               ),
//                             ),
//                             Text(
//                               rides['speed'] + " Km/h",
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               "Price",
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: fontSecondColor,
//                               ),
//                             ),
//                             Text(
//                               rides['price'],
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 14,
//                                 color: Colors.black,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     // Forward button
//                     Expanded(
//                       child: Container(
//                         height: 38,
//                         width: 38,
//                         margin: EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: bicycleAppColor,
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         child: Center(
//                           child: IconButton(
//                             onPressed: () {
//                               Sheet(rides);
//                             },
//                             icon: Icon(Icons.arrow_forward, color: Colors.white),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   ],
// );




// Assuming Rent_home is stored as GeoPoint in Firestore
// GeoPoint rentHomeGeoPoint = rides['Rent_home'];
//
//
// LatLng? currentHomeLatLng = authController.myUser.value.homeAddress;
//
//
// final dist = calculateDistanceBetweenAddresses(rentHomeGeoPoint, currentHomeLatLng!);