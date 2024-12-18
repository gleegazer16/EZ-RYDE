import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:green_taxi_mine/controller/auth_controller.dart';
import 'package:green_taxi_mine/views/driver/car_registration/car_registration_template.dart';
import 'package:green_taxi_mine/views/login_screen.dart';

 import '../../widgets/green_intro_widget.dart';
import '../../widgets/my_button.dart';
import '../driver/profile_setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DecisionScreen extends StatelessWidget {
    DecisionScreen({Key? key}) : super(key: key);


    AuthController authController = Get.find<AuthController>();

  @override
  @override
  void initState() {

    // Set the system UI mode and overlay style for this page
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      statusBarColor: Colors.white,
    ));
  }

    @override
    void dispose() {
      // Reset to the default system UI mode and overlay style when leaving this page
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black,
        statusBarColor: Colors.black,
      ));

    }

    void loginAsUser() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoginAsDriver', false);
      authController.isLoginAsDriver = false;
      authController.update();
      Get.to(() => LoginScreen());
    }

    void loginAsDriver() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoginAsDriver', true);
      authController.isLoginAsDriver = true;
      authController.update();
      Get.to(() => LoginScreen());
    }


    Widget build(BuildContext context) {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   systemNavigationBarColor: Colors.white,
    //   statusBarColor: Colors.white
    // ));
    return Scaffold(
      body: Container(
        color: Colors.white,
        width: double.infinity,
        child: Column(
          children: [
            greenIntroWidget(),

            const SizedBox(height: 50,),

            DecisionButton(
              'assets/driver.png',
              'Login As Driver',
                (){
                // authController.isLoginAsDriver = true;
                //   Get.to(()=> LoginScreen());
                  loginAsDriver();
                },
              Get.width*0.8
            ),

            const SizedBox(height: 20,),
            DecisionButton(
                'assets/customer.png',
                'Login As User',
                    (){
                   //    authController.isLoginAsDriver = false;
                   // Get.to(()=> LoginScreen());
                      loginAsUser();
                   },
                Get.width*0.8
            ),
          ],
        ),
      ),
    );
  }
}
