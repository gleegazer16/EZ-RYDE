import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class UploadDocumentPage extends StatefulWidget {
  const UploadDocumentPage({Key? key, required this.onImageSelected}) : super(key: key);

  final Function(List<File>) onImageSelected;

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();

  getImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      selectedImages = images.map((image) => File(image.path)).toList();
      widget.onImageSelected(selectedImages);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Upload (RC, License, Aadhaar)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black),
          ),
          SizedBox(height: 30),

          // GestureDetector to open the image picker
          GestureDetector(
            onTap: getImages,
            child: Container(
              width: Get.width,
              height: Get.height * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Color(0xffE3E3E3).withOpacity(0.4),
                border: Border.all(color: Color(0xff2FB654).withOpacity(0.26), width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, size: 40, color: selectedImages.isEmpty? Color(0xff7D7D7D):Colors.green),
                  Text(
                    selectedImages.isEmpty ? 'Tap here to upload ' : 'Documents are selected.',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xff7D7D7D)),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Display selected images in a GridView
          selectedImages.isNotEmpty
              ? GridView.builder(
            shrinkWrap: true,
            itemCount: selectedImages.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return Image.file(
                selectedImages[index],
                fit: BoxFit.cover,
              );
            },
          )
              : Container(), // Empty container when no image is selected
        ],
      ),
    );
  }
}
