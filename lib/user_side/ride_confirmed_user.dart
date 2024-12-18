import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:fluttertoast/fluttertoast.dart';
import 'package:green_taxi_mine/customer_side/customer_bottom_bar.dart';
import 'package:green_taxi_mine/customer_side/home.dart'; // For toast messages

class RideConfirmedScreen extends StatefulWidget {
   final Map<String,dynamic> data;

  const RideConfirmedScreen({super.key, required this.data});
  @override
  State<RideConfirmedScreen> createState() => _RideConfirmedScreenState();
}

class _RideConfirmedScreenState extends State<RideConfirmedScreen> {
  final String vehicleNumber = 'TN07 AB1234'; // Vehicle number to copy

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride Confirmed'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 30),
            Icon(
              Icons.check_circle,
              size: 100,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Ride Confirmed!',
              style: TextStyle(
                  fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 10),
            Text(
              'Driver is on the way. Hang tight!',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 30),
            // Driver details section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(
                        widget.data['driver_profile']),
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Driver: ${widget.data['driver_name']}',
                          style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Number: ${widget.data['driver_number']}',
                          style: TextStyle(fontSize: 16)),
                      Text('Arrival: 2 mins',
                          style: TextStyle(fontSize: 16, color: Colors.green)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Buttons: Copy Number & Back to Home
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text:widget.data['driver_number'])).then((_) {
                      // Show a toast notification when the copy is successful
                      Fluttertoast.showToast(
                          msg: 'Vehicle number copied to clipboard!',
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white);
                    });
                  },
                  icon: Icon(Icons.copy),
                  label: Text('Copy Number'),
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomBarCustomer(),
                      ),
                    );

                  },
                  icon: Icon(Icons.home),
                  label: Text('Back to Home'),
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            // Footer section: ETA bar and live tracking
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: Colors.green),
                SizedBox(width: 10),
                Text(
                  'Your driver is 3.4 km away',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }




}
