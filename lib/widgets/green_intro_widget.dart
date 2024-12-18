import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:green_taxi_mine/utils/app_colors.dart';

Widget greenIntroWidget() {
  return Container(
    width: Get.width,
    decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
      Colors.white,
      Colors.white,
    ])
        // image: DecorationImage(
        //   image: AssetImage('assets/mask.png'),
        //   fit: BoxFit.cover
        // )
        //color: Color(0xFFebf8fe),

        ),
    height: Get.height * 0.6,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // SvgPicture.asset('assets/leaf icon.svg'),
        Image(image: AssetImage('assets/cycle4.gif')),

        const SizedBox(
          height: 20,
        ),

        Image(
          image: AssetImage(
            'assets/thapar.png',
          ),
          height: 60,
          width: 70,
        ),
        SizedBox(
          height: 10,
        ),
        // Text('EZ-Ryde',
        // style: TextStyle(
        //   fontSize: 50,
        //   fontWeight: FontWeight.bold,
        //   color: AppColors.greenColor,
        //   fontFamily: 'fontMain3',
        // ),
        // ),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF920409), Color(0xFFe71127),Color(0xFFf74b3e),Color(0xFFa21619)],
            // Replace with your desired colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child:
          Text(
            'EZ-Ryde',
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              // This color will be used as a base before the gradient is applied
              fontFamily: 'fontMain3',
            ),
          ),
        ),

        SizedBox(
          height: 10,
        ),

        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF920409), Color(0xFFe71127),Color(0xFFf74b3e),Color(0xFFa21619)],
            // Replace with your desired colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child:
          Text(
            'Ride Across Campuss',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'fontMain3',
            ),
          ),
         ),
      ],
    ),
  );
}

Widget greenIntroWidgetWithoutLogos(
    {String title = "Profile Settings", String? subtitle}) {
  return Container(
    width: Get.width,
    decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage('assets/mask.png'), fit: BoxFit.fill),
    ),
    height: Get.height * 0.3,
    child: Container(
        height: Get.height * 0.1,
        width: Get.width,
        margin: EdgeInsets.only(bottom: Get.height * 0.05),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
          ],
        )),
  );
}
