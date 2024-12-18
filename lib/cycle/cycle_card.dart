import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:green_taxi_mine/customer_side/customer_bottom_bar.dart';

import '../controller/auth_controller.dart';

class CycleCard extends StatefulWidget {
  @override
  _CycleCardState createState() => _CycleCardState();
}

class _CycleCardState extends State<CycleCard> {
  File? _backgroundImage;
  bool isLoading = false;

  Future<void> _pickBackgroundImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        _backgroundImage = File(result.files.single.path!);
      });
    }
  }

 // final price = TextEditingController();
  final time = TextEditingController();
  final rate = TextEditingController();
  final model = TextEditingController();
  AuthController authController = Get.find<AuthController>();

  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection('Rent');

  Future<String> uploadImage(String fileName, File file) async {
    final reference =
        FirebaseStorage.instance.ref().child("Cycle/$fileName.jpg");
    final uploadTask = reference.putFile(file);

    await uploadTask.whenComplete(() => {});

    final downloadLink = await reference.getDownloadURL();
    return downloadLink;
  }

  void onSubmit() async {
    setState(() {
      isLoading = true; // Disable button
    });

    await addUser(); // Wait for the addUser function to complete

    setState(() {
      isLoading = false; // Enable button after completion
    });

    // Navigate to BottomBarCustomer after completion
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BottomBarCustomer(),
      ),
    );
  }

  Future<void> addUser() async {
    if (_backgroundImage != null) {
      String backgroundFilePath = _backgroundImage!.path;

      File backgroundFile = File(backgroundFilePath);
      try {
        String backgroundFileName = backgroundFilePath.split('/').last;
        final cycle_link =
            await uploadImage(backgroundFileName, backgroundFile);

        var docRef = users.doc(); // Create a single document reference

        return docRef
            .set({
              'cycle': cycle_link,
              'name': model.text,
              'rate': rate.text,
              'time': time.text,
              //'price': price.text,
              'uid': user!.uid,
              'Rent_home': GeoPoint(
                  authController.myUser.value.homeAddress!.latitude,
                  authController.myUser.value.homeAddress!.longitude),
              'owner_name': authController.myUser.value.name!,
              'owner_profile': authController.myUser.value.image!,
              'owner_address_place': authController.myUser.value.hAddress,
              'owner_number': user?.phoneNumber,
              'postId':
                  docRef.id, // Use the id from the same document reference
            })
            .then((value) => setState(() {}))
            .catchError((error) => print("Failed to add user: $error"));
      } catch (error) {
        print("Error uploading image: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Cycle Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickBackgroundImage,
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Background color
                    image: _backgroundImage != null
                        ? DecorationImage(
                            image: FileImage(_backgroundImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _backgroundImage == null
                      ? Center(
                          child: Icon(Icons.add_photo_alternate_outlined,
                              size: 80, color: Colors.grey[400]),
                        )
                      : null,
                ),
              ),
              SizedBox( height: MediaQuery.of(context).size.height*0.05,),
              buildInputNameField('Model Name', model),
              SizedBox( height: MediaQuery.of(context).size.height*0.03,),
              buildInputField('Rent/hour', rate),
              SizedBox( height: MediaQuery.of(context).size.height*0.03,),
              buildInputNameField('Available Time', time),
              // buildInputNameField('Price', price),
              // SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height*0.12,
              ),
              isLoading
                  ? CircularProgressIndicator(
                color: Colors.black,
              ):ElevatedButton(
                onPressed: () {
                  onSubmit();
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  primary: Colors.teal,
                ),
                child: Text(
                  'Rent',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildInputNameField(
      String hintText, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget buildInputField(String hintText, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        controller: controller,
        style: TextStyle(fontSize: 18),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          hintText: hintText,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
