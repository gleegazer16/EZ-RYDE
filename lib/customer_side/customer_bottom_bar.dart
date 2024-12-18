import 'package:flutter/material.dart';
import 'package:green_taxi_mine/customer_side/bicycle.dart';
import 'package:green_taxi_mine/customer_side/cycle_ride_history.dart';
import 'package:green_taxi_mine/utils/app_colors.dart';
import 'package:green_taxi_mine/customer_side/home.dart';
import 'package:green_taxi_mine/customer_side/my_profile.dart';

class BottomBarCustomer extends StatefulWidget {
  const BottomBarCustomer({super.key});

  @override
  State<BottomBarCustomer> createState() =>
      _BottomBarCustomerState();
}

class _BottomBarCustomerState
    extends State<BottomBarCustomer> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static  List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    Bicycle(),
    CycleHistoryPage(),
    MyProfile()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Container(
        height: 107, // Decrease the height as needed
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '',
              backgroundColor: Colors.white// Remove label
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.motorcycle),
              label: '', // Remove label
               backgroundColor: Colors.white
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: '', // Remove label
                backgroundColor: Colors.white
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: '', // Remove label
                backgroundColor: Colors.white
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          unselectedItemColor: AppColors.blackColor,
          onTap: _onItemTapped,
          showSelectedLabels: false, // Hide selected labels
          showUnselectedLabels: false, // Hide unselected labels
        ),
      ),
    );
  }
}
