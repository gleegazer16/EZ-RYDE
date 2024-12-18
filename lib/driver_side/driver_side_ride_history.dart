import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:green_taxi_mine/cycle/api.dart';
import 'package:intl/intl.dart';

class DriverSideHistory extends StatefulWidget {
  @override
  _DriverSideHistoryState createState() => _DriverSideHistoryState();
}

class _DriverSideHistoryState extends State<DriverSideHistory>
    with SingleTickerProviderStateMixin {
  String getFormattedTime(DateTime timestamp) {
    // Format the time in the format 3:45 PM, 12 Jan, 22
    return DateFormat('h:mm a, dd MMM, yy').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
                top: 40.0, left: 40, right: 40, bottom: 10),
            child: Text(
              'Ride History',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder(
            stream: APIs.getAutoRideHistory(),
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
                    Map<String, dynamic> history = snapshot.data!.docs[index]
                        .data() as Map<String, dynamic>;

                    String srcName = history['src_name'].split(',').first;
                    String destName = history['dest_name'].split(',').first;
                    DateTime timeBooked =
                        (history['time'] as Timestamp).toDate();
                    final dist = 5; // Placeholder for calculated distance

                    return Column(
                      children: [
                        Visibility(
                          visible: history['user_id'] ==
                                  APIs.auth.currentUser!.uid ||
                              history['driver_id'] ==
                                  APIs.auth.currentUser!.uid,
                          child: RideBookingCard(
                            sourceAddress: srcName,
                            destinationAddress: destName,
                            timeBooked: getFormattedTime(timeBooked),
                            numberOfPeople: history['number_of_riders'],
                            autoDriverName: history['driver_name'],
                            autoDriverProfileUrl: history['driver_profile'],
                            autoDriverContact: history['driver_number'],
                            ownerName: history['user_name'],
                            ownerProfileUrl: history['user_profile'],
                            ownerContact: history['user_number'],
                            ratePerPerson: 10,
                          ),
                        ),
                      ],
                    );
                  },
                );
              }
              return Padding(
                padding: const EdgeInsets.only(top: 350),
                child: Center(
                  child: Text(
                    'No Rides Available',
                    style: TextStyle(color: Colors.black54, fontSize: 22),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ));
  }
}

class RideBookingCard extends StatefulWidget {
  final String sourceAddress;
  final String destinationAddress;
  final String timeBooked;
  final String numberOfPeople;
  final String autoDriverName;
  final String autoDriverProfileUrl;
  final String autoDriverContact;
  final String ownerName;
  final String ownerProfileUrl;
  final String ownerContact;
  final double ratePerPerson;

  RideBookingCard({
    required this.sourceAddress,
    required this.destinationAddress,
    required this.timeBooked,
    required this.numberOfPeople,
    required this.autoDriverName,
    required this.autoDriverProfileUrl,
    required this.autoDriverContact,
    required this.ownerName,
    required this.ownerProfileUrl,
    required this.ownerContact,
    required this.ratePerPerson,
  });

  @override
  State<RideBookingCard> createState() => _RideBookingCardState();
}

class _RideBookingCardState extends State<RideBookingCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.orange.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Source and Destination Addresses
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Source:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.sourceAddress,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destination:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    ),
                    SizedBox(height: 4),
                    Text(
                      widget.destinationAddress,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: Colors.orangeAccent.withOpacity(0.5)),

            // Auto Driver Information
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child:CachedNetworkImage(
                    imageUrl: widget.autoDriverProfileUrl,
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                  ),
                ),

                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Driver:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orangeAccent),
                    ),
                    SizedBox(height: 6),
                    Text(
                      widget.autoDriverName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Contact: ${widget.autoDriverContact}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),

            // Rider Information
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child:CachedNetworkImage(
                    imageUrl: widget.ownerProfileUrl,
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                // CircleAvatar(
                //   radius: 28,
                //   backgroundImage: NetworkImage(widget.ownerProfileUrl),
                //   backgroundColor: Colors.blue.shade100,
                // ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rider:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      widget.ownerName,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Contact: ${widget.ownerContact}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            Divider(color: Colors.orangeAccent.withOpacity(0.5)),

            // Ride Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.grey[700], size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Booked at: ${widget.timeBooked}',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.grey[700], size: 18),
                    SizedBox(width: 6),
                    Text(
                      '${widget.numberOfPeople} People',
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
