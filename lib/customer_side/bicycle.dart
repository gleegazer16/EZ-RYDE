import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:green_taxi_mine/cycle/api.dart';
import 'package:green_taxi_mine/cycle/booking_confirmed_page.dart';
import 'package:green_taxi_mine/cycle/cycle_card.dart';

import '../controller/auth_controller.dart';

const Color fontMainColor = Color(0xff293038);
const Color fontSecondColor = Color(0xff696e74);
const Color bicycleAppColor = Color(0xffffc329);


class Bicycle extends StatefulWidget {
  const Bicycle({super.key});

  @override
  State<Bicycle> createState() => _BicycleState();
}

class _BicycleState extends State<Bicycle> {
  AuthController authController = Get.find<AuthController>();



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
            onPressed: () async {
              // Step 1: Run cycleHistory first
              await APIs.cycleHistory(cycle);

              // Step 2: Move to the next page (BookingConfirmedPage)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => BookingConfirmedPage(cycle: cycle)),
              );
              // Step 3: Delete the rent after navigation
              await APIs.deleteRent(cycle['postId']);
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
      body: SingleChildScrollView(
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
                              TextSpan(text: "Select ", style: TextStyle(color: fontSecondColor, fontSize: 22)),
                              TextSpan(
                                  text: "Bicycle",
                                  style: TextStyle(color: fontMainColor, fontSize: 22, fontWeight: FontWeight.bold)),
                            ])),
                            Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: "To Ride ",
                                  style: TextStyle(color: fontMainColor, fontSize: 22, fontWeight: FontWeight.bold)),
                              TextSpan(text: "Now.", style: TextStyle(color: fontSecondColor, fontSize: 22)),
                            ])),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 0,
                      child: Container(
                        height: 160,
                        width: 170,
                        // decoration: BoxDecoration(
                        //     border: Border.all(color: bicycleAppColor), borderRadius: BorderRadius.circular(10)),
                        child: Container(
                            width: 120,
                            height: 120,
                            margin: EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                          image: DecorationImage(
                              image: AssetImage('assets/rider.gif'),
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
                      width: 70,
                      child: Stack(
                        children: [
                          Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: Text(
                                  "Popular",
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
              stream:APIs.getRentCycles(),
              builder: (context,snapshot) {

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData  &&  snapshot.data!.docs.isNotEmpty) {
                  return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> cycle = snapshot.data!.docs[index]
                            .data() as Map<String, dynamic>;
                        // Assuming Rent_home is stored as GeoPoint in Firestore
                        GeoPoint rentHomeGeoPoint = cycle['Rent_home'];


                        LatLng? currentHomeLatLng = authController.myUser.value.homeAddress;


                        final dist = calculateDistanceBetweenAddresses(rentHomeGeoPoint, currentHomeLatLng!);
                        return GestureDetector(
                          onTap: () {
                            if(cycle['uid']!=APIs.auth.currentUser!.uid){
                              Sheet(cycle);
                            }
                            },
                          child: Container(
                            height: MediaQuery.of(context).size.height / 4, // Set height
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              color: Colors.white,
                              child: Row(
                                children: [
                                  // Left side with the details
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                cycle['name'], // Cycle name
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              Visibility(
                                                visible:cycle['uid']==APIs.auth.currentUser!.uid,
                                                child: IconButton(
                                                    onPressed:()async{
                                                     await APIs.deleteCycle(cycle['postId']);
                                                    },
                                                    icon: Icon(Icons.delete,color: Colors.red,)
                                                ),
                                              )
                                            ],
                                          ),

                                         Spacer(), // Add spacing
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: cycle['rate'] + " \R\s\. ",
                                                  style: TextStyle(
                                                    color: bicycleAppColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "/ hour",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: fontSecondColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Spacer(), // Pushes details up
                                          // Distance and Speed
                                          Padding(
                                            padding: const EdgeInsets.only(right: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Distance",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: fontSecondColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      dist.toStringAsFixed(2) + " Km",
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "Time Aval",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: fontSecondColor,
                                                      ),
                                                    ),
                                                    Text(
                                                      cycle['time'],
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  // Right side with the image
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(15),
                                          bottomRight: Radius.circular(15),
                                        ),
                                        image: DecorationImage(
                                          image: NetworkImage(cycle['cycle']), // Network image
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                      }
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 200),
                  child: Center(child: Text('No Rides Available',style: TextStyle(color: fontSecondColor, fontSize: 22),)),
                );
              }
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(onPressed: (){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CycleCard(),
          ),
        );
      },
        child: Icon(Icons.add,color: Colors.white,),
      backgroundColor: bicycleAppColor,
      ),
    );
  }
}
