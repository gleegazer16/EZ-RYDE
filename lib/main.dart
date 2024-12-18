import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:green_taxi_mine/utils/app_colors.dart';
import 'package:green_taxi_mine/views/decision_screen/decission_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:green_taxi_mine/customer_side/home.dart';
import 'package:green_taxi_mine/views/login_screen.dart';
import 'package:green_taxi_mine/views/profile_settings.dart';
import 'controller/auth_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
    statusBarColor: Colors.transparent,
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthController authController = Get.put(AuthController());
    authController.decideRoute();
    final textTheme = Theme.of(context).textTheme;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(textTheme),
      ),
      home: FutureBuilder(
        future: Future.delayed(Duration(milliseconds: 1300)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                  child: CircularProgressIndicator(color: Colors.black,)),
            ); // Optional loading screen
          } else {
            return DecisionScreen();
          }
        },
      ),

      //  home:ProfileSettingScreen()
    );
  }
}
