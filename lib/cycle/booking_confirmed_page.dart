import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:green_taxi_mine/customer_side/customer_bottom_bar.dart';
import 'package:green_taxi_mine/cycle/api.dart';
import 'package:intl/intl.dart';
DateTime now = DateTime.now();
class BookingConfirmedPage extends StatefulWidget {
 final Map<String, dynamic> cycle;
  BookingConfirmedPage({super.key, required this.cycle});
  @override
  State<BookingConfirmedPage> createState() => _BookingConfirmedPageState();
}

class _BookingConfirmedPageState extends State<BookingConfirmedPage> {

  String formattedDate = DateFormat('d MMM y').format(now);
  String formattedTime = DateFormat('hh:mm a').format(now);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 120,
              ),
              SizedBox(height: 24),
              Text(
                'Booking Confirmed!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Confirm booking by calling the owner',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 30),


              // Container for renter's details (photo, name, mobile, address)
              // StreamBuilder(
              //   stream: APIs.getRentCycles(),
              //   builder: (context, snapshot) {
              //     if (snapshot.hasError) {
              //       return Text('Error: ${snapshot.error}');
              //     }
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return Center(child: CircularProgressIndicator());
              //     }
              //     if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              //       Map<String, dynamic> cycle =
              //       snapshot.data!.docs[widget.lendIndex].data()
              //       as Map<String, dynamic>;
              //       return
                         Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Renter's profile picture and name
                                Row(
                                  children: [
                                    CachedNetworkImage(
                                      imageUrl: widget.cycle['owner_profile'],
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                            width: 70,
                                            height: 70,
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
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.cycle['owner_name'],
                                          // Replace with renter's name
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          'Mobile: ${widget.cycle['owner_number']}',
                                          // Replace with actual mobile number
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                // Address Section
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.location_pin,
                                        color: Colors.blueAccent),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        widget.cycle['owner_address_place'],
                                        // Replace with actual address
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                // Date and Time Section
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.calendar_today,
                                        color: Colors.blueAccent),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Date: $formattedDate\nTime: $formattedTime',
                                        // Replace with actual date and time
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

              //     }
              //     return Padding(
              //       padding: const EdgeInsets.only(top: 100),
              //       child: Center(child: Text('No data available')),
              //     );
              //   },
              // ),
                 SizedBox(height: 30),

              // Call Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>BottomBarCustomer()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Go to Home',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
