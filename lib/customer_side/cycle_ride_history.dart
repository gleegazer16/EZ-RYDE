import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:green_taxi_mine/cycle/api.dart';
import 'package:intl/intl.dart';

class CycleHistoryPage extends StatefulWidget {
  @override
  _CycleHistoryPageState createState() => _CycleHistoryPageState();
}

class _CycleHistoryPageState extends State<CycleHistoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    _tabController.animateTo(index);
  }

  void _onTabChanged() {
    _pageController.jumpToPage(_tabController.index);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(left: 120.0),
          child: Text(
            'Ride History',
            style: TextStyle(color: Colors.black38, fontSize: 22),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) => _onTabChanged(),
          tabs: [
            Tab(text: 'Cycle Rides',),
            Tab(text: 'Auto Rides'),
          ],
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.amber,
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          // Lend History Page
          LendHistoryPage(),

          // Rent History Page
          AutoCustomerSide()
        ],
      ),
    );
  }
}

class LendHistoryPage extends StatefulWidget {
  @override
  State<LendHistoryPage> createState() => _LendHistoryPageState();
}

class _LendHistoryPageState extends State<LendHistoryPage> {
  String getFormattedTime(DateTime timestamp) {
    // Format the time in the format 3:45 PM, 12 Jan, 22
    return DateFormat('h:mm a, dd MMM, yy').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: APIs.getCycleRideHistory(),
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
              Map<String, dynamic> history =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              String owner_address = history['owner_address'].split(',').first;
              String lender_address = history['lender_address'].split(',').first;
              DateTime timeBooked = (history['time'] as Timestamp).toDate();

              return Visibility(
                visible: history['owner_id'] ==
                    APIs.auth.currentUser!.uid ||
                    history['lender_id'] ==
                        APIs.auth.currentUser!.uid,
                child: Padding(
                  padding:  EdgeInsets.only(left: 8.0,right: 8.0,top: 20),
                  child: CycleCard(
                    cycleName: history['cycle_name'],
                    cycleOwnerName: history['owner_name'],
                    cycleOwnerAddress: owner_address,
                    cycleOwnerProfileUrl: history['owner_profile'],
                    cycleLenderName: history['lender_name'],
                    cycleLenderAddress: lender_address,
                    cycleLenderProfileUrl: history['lender_profile'],
                    cycleImageUrl: history['cycle_profile'],
                    rentTime: getFormattedTime(timeBooked),
                    ratePerHour: history['rate'],
                    cycleOwnerNumber: history['owner_number'],
                    cycleLenderNumber: history['lender_number'],

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
              style: TextStyle(color: Colors.grey[300], fontSize: 22),
            ),
          ),
        );
      },
    );
  }
}

class CycleCard extends StatelessWidget {
  final String cycleName;
  final String cycleOwnerName;
  final String cycleOwnerAddress;
  final String cycleOwnerProfileUrl;
  final String cycleLenderName;
  final String cycleLenderAddress;
  final String cycleLenderProfileUrl;
  final String cycleImageUrl;
  final String rentTime;
  final String ratePerHour;
  final String cycleOwnerNumber;
  final String cycleLenderNumber;

  CycleCard({
    required this.cycleName,
    required this.cycleOwnerName,
    required this.cycleOwnerAddress,
    required this.cycleOwnerProfileUrl,
    required this.cycleLenderName,
    required this.cycleLenderAddress,
    required this.cycleLenderProfileUrl,
    required this.cycleImageUrl,
    required this.rentTime,
    required this.ratePerHour,
    required this.cycleOwnerNumber,
    required this.cycleLenderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 16,horizontal: 10),
      elevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.orange.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cycle Image and Cycle Name
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child:CachedNetworkImage(
                      imageUrl: cycleImageUrl,
                    height: 55,
                    width: 55,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Text(
                    cycleName,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            // SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.only(left:10.0,right: 10.0),
              child: Divider(color: Colors.blueAccent.withOpacity(0.5)),
            ),
            // Owner Information (New vertical layout)
            _buildProfileSection(
              title: 'Owner',
              profileImageUrl: cycleOwnerProfileUrl,
              name: cycleOwnerName,
              address: cycleOwnerAddress,
              backgroundColor: Colors.blue.shade100,
              contact: cycleOwnerNumber,
            ),

            SizedBox(height: 5),

            // Lender Information (New vertical layout)
            _buildProfileSection(
              title: 'Borrower',
              profileImageUrl: cycleLenderProfileUrl,
              name: cycleLenderName,
              address: cycleLenderAddress,
              backgroundColor: Colors.orange.shade100,
              contact: cycleLenderNumber,
            ),

          //  SizedBox(height: 16),
            Padding(
              padding:  EdgeInsets.only(left: 10.0,right: 10.0),
              child: Divider(color: Colors.blueAccent.withOpacity(0.5)),
            ),

            // Rental Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Hours rented
                Row(
                  children: [
                    Icon(Icons.access_time_filled, color: Colors.grey[700]),
                    SizedBox(width: 6),
                    Text(
                      '$rentTime',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
                // Rate per hour
                Row(
                  children: [
                    Icon(Icons.currency_rupee, color: Colors.grey[700]),
                    Text(
                      '${ratePerHour}/hr',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
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

  Widget _buildProfileSection({
    required String title,
    required String profileImageUrl,
    required String name,
    required String address,
    required Color backgroundColor,
    required String contact,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: backgroundColor == Colors.blue.shade100
                ? Colors.blueAccent
                : Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            // CircleAvatar(
            //   radius: 30,
            //  // backgroundImage: NetworkImage(profileImageUrl),
            //   backgroundColor: backgroundColor,
            //   child: CachedNetworkImage(
            //     imageUrl: profileImageUrl,
            //     height: 55,
            //     width: 55,
            //     fit: BoxFit.cover,
            //   ),
            // ),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child:CachedNetworkImage(
                imageUrl: profileImageUrl,
                height: 55,
                width: 55,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Contact : ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      contact,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}


class AutoCustomerSide extends StatefulWidget {
  @override
  _AutoCustomerSideState createState() => _AutoCustomerSideState();
}

class _AutoCustomerSideState extends State<AutoCustomerSide>
    with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
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
              Map<String, dynamic> history =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              String srcName = history['src_name'].split(',').first;
              String destName = history['dest_name'].split(',').first;
              DateTime timeBooked = (history['time'] as Timestamp).toDate();
              final dist = 5; // Placeholder for calculated distance

              return Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 20),
                    child: Visibility(
                      visible: history['user_id'] ==
                              APIs.auth.currentUser!.uid ||
                          history['driver_id'] == APIs.auth.currentUser!.uid,
                      child: RideBookingCardCustomer(
                        sourceAddress: srcName,
                        destinationAddress: destName,
                        timeBooked: getTimeAgo(timeBooked),
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
                  ),
                ],
              );
            },
          );
        }
        return Padding(
          padding: const EdgeInsets.only(top: 200),
          child: Center(
            child: Text(
              'No Rides Available',
              style: TextStyle(color: Colors.grey[300], fontSize: 22),
            ),
          ),
        );
      },
    )
    );
  }
}

class RideBookingCardCustomer extends StatefulWidget {
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

  RideBookingCardCustomer({
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
  State<RideBookingCardCustomer> createState() =>
      _RideBookingCardCustomerState();
}

class _RideBookingCardCustomerState extends State<RideBookingCardCustomer> {
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
                // CircleAvatar(
                //   radius: 28,
                //   backgroundImage: NetworkImage(widget.autoDriverProfileUrl),
                //   backgroundColor: Colors.orange.shade100,
                // ),

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
                          color: Colors.blueAccent),
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
