import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:green_taxi_mine/driver_side/driver_bottom_bar.dart';
import 'package:green_taxi_mine/driver_side/ride_completed.dart';
import 'dart:ui' as ui;
import '../controller/auth_controller.dart';
import '../controller/polyline_handler.dart';

class DriverHomeScreen extends StatefulWidget {
  final LatLng? source;
  final LatLng? destination;
  const DriverHomeScreen({Key? key, this.source, this.destination}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  String? _mapStyle;
  AuthController authController = Get.find<AuthController>();
  final Set<Polyline> _polyline = {};
  Set<Marker> markers = Set<Marker>();
  GoogleMapController? myMapController;
  Position? currentPosition;
  late Stream<Position> positionStream;
  double? distanceBetween;
  late Uint8List markIcons;

  @override
  void initState() {
    super.initState();
    markers.clear();
    polyList.clear();
    authController.getDriverInfo();
    rootBundle.loadString('assets/map_style.txt').then((string) {
      _mapStyle = string;
    });
    loadCustomMarker();
    _startLocationUpdates();

    if (widget.source != null && widget.destination != null) {
      mapping();
      calculateDistance(widget.source!); // Initial distance calculation
    } else {
      display();
    }
  }

  void calculateDistance(LatLng currentPosition) {
    if (widget.destination != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        widget.destination!.latitude,
        widget.destination!.longitude,
      );

      setState(() {
        distanceBetween = distanceInMeters;
      });
    }
  }

  void _startLocationUpdates() async {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1,
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings);
    positionStream.listen((Position position) {
      LatLng newSourcePosition = LatLng(position.latitude, position.longitude);

      setState(() {
        currentPosition = position;
        _updateSourceMarker(newSourcePosition);

        if (widget.destination != null) {
          calculateDistance(newSourcePosition); // Update distance here
          updatePolyline(newSourcePosition, widget.destination!);
        }
      });
    });
  }

  void _updateSourceMarker(LatLng newSourcePosition) {
    setState(() {
      markers.removeWhere((m) => m.markerId == MarkerId('Source')); // Remove old marker
      markers.add(
        Marker(
          markerId: MarkerId('Source'),
          position: newSourcePosition,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
    // Move camera to new position
    myMapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newSourcePosition, zoom: 18.5),));
  }

  void updatePolyline(LatLng newSource, LatLng destination) async {
    polyList.clear();
    _polyline.clear();

    // Fetch polyline points from the Directions API
    List<LatLng> routePoints = await getPolylines(newSource, destination);

    setState(() {
      _polyline.add(
        Polyline(
          polylineId: PolylineId("route"),
          visible: true,
          points: routePoints,
          width: 5,
          color: Colors.blue,
        ),
      );
    });
  }

  display() {
    print('Source or destination not available');
  }

  void mapping() async {
    await loadCustomMarker();
    setState(() {
      markers.add(
        Marker(
          markerId: const MarkerId('Destination'),
          position: widget.destination!,
          icon: BitmapDescriptor.fromBytes(markIcons),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('Source'),
          position: widget.source!,
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });

    updatePolyline(widget.source!, widget.destination!);

    await myMapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: widget.source!, zoom: 19.5),
      ),
    );
    setState(() {});
  }

  final CameraPosition _kThaparUniv = CameraPosition(
    target: LatLng(30.3564, 76.3647),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              child: GoogleMap(
                mapType: MapType.terrain,
                markers: markers,
                polylines: _polyline,
                zoomControlsEnabled: false,
                onMapCreated: (GoogleMapController controller) {
                  myMapController = controller;
                  myMapController!.setMapStyle(_mapStyle);
                },
                initialCameraPosition: _kThaparUniv,
              ),
            ),
            buildProfileTile(),
            buildCurrentLocationIcon(),
            widget.destination != null ? buildFloatingDistanceStop() : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget buildProfileTile() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Obx(() => authController.myDriver.value.name == null
          ? Center(child: CircularProgressIndicator())
          : Container(
        width: Get.width,
        height: Get.width * 0.4,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(color: Colors.white70),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: authController.myDriver.value.image == null
                    ? DecorationImage(
                  image: AssetImage('assets/person.png'),
                  fit: BoxFit.fill,
                )
                    : null,
              ),
              child: authController.myDriver.value.image == null
                  ? null
                  : CachedNetworkImage(
                imageUrl: authController.myDriver.value.image!,
                imageBuilder: (context, imageProvider) => Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: 'Good Morning, ',
                          style: TextStyle(color: Colors.black, fontSize: 14)),
                      TextSpan(
                          text: authController.myDriver.value.name,
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text(
                  "Where are you going?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                )
              ],
            )
          ],
        ),
      )),
    );
  }

  Widget buildCurrentLocationIcon() {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 8),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.green,
          child: IconButton(
            onPressed: () async {
              Position position = await Geolocator.getCurrentPosition(
                  desiredAccuracy: LocationAccuracy.high);
              LatLng newSource = LatLng(position.latitude, position.longitude);
              _updateSourceMarker(newSource);
            },
            icon: Icon(Icons.my_location, color: Colors.white),
          ),
        ),
      ),
    );
  }

  loadCustomMarker() async {
    markIcons = await loadAsset('assets/dest_marker.png', 100);
  }

  Future<Uint8List> loadAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetHeight: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Widget buildFloatingDistanceStop() {
    if (distanceBetween != null && distanceBetween! < 10) {
      // Automatically navigate to RideCompletionPage if distance is less than 5 meters
      Future.microtask(() => Get.to(() => RideCompletionScreen()));
      return SizedBox(); // Return an empty widget since navigation has occurred
    }

    return Positioned(
      bottom: 40,
      left: 80,
      right: 80,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          children: [
            Text(
              distanceBetween != null
                  ? "${(distanceBetween!).toStringAsFixed(2)} m away"
                  : "Calculating distance...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () {
                Get.to(() => DriverBottomBar());
              },
              child: Text('Stop'),
            ),
          ],
        ),
      ),
    );
  }

}
