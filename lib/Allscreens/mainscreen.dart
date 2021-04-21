import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tourist_app/AllWidgets/divider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tourist_app/Allscreens/searchScreen.dart';
import 'package:tourist_app/Assistants/assistantMethods.dart';
import 'package:tourist_app/DataHandler/appData.dart';
import 'package:tourist_app/Models/directDetails.dart';
import 'package:tourist_app/services/places_service.dart';
import 'package:tourist_app/services/geolocator_service.dart';
import 'package:tourist_app/screens/search.dart';
import 'package:tourist_app/models/place.dart';

class MainScreen extends StatefulWidget {
  static const String idScreen = "mainScreen";

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  DirectionDetails tripDirectionDetails;

  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polylineSet = {};

  double bottomPaddingOfMap = 0;

  Set<Marker> markerSet = {};
  Set<Circle> circlesSet = {};

  double distanceContainerHeight = 0;

  void displayDistanceContainer() async {
    await getPlaceDirection();
    setState(() {
      distanceContainerHeight = 40;
    });
  }

  Position currentPosition;
  var geoLocator = Geolocator();

  void locatePosition() async {
    Position position = await geoLocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLatPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLatPosition, zoom: 17.0);
    newGoogleMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await AssistantMethods.searchCoordinateAddress(position, context);
    print("This is your Address :: " + address);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    // tilt: 75.000000,
    bearing: -106.54456456,
    target: LatLng(25.262014, 82.992315),
    zoom: 18.4746,
  );

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(
          "Voyage!",
          style: TextStyle(fontFamily: "Brand Bold"),
        ),
      ),
      drawer: Container(
        color: Colors.black,
        width: 260.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.white),
                  child: Row(
                    children: [
                      Image.asset(
                        "images/user_icon.png",
                        height: 55.0,
                        width: 55.0,
                      ),
                      SizedBox(
                        width: 16.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Profile Name",
                            style: TextStyle(
                                fontSize: 16.0, fontFamily: "Brand-Regular"),
                          ),
                          SizedBox(
                            height: 6.0,
                          ),
                          Text("Visit Profile"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              DividerWidget(),
              SizedBox(
                height: 12.0,
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  "History",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  "Visit Profile",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  "About",
                  style: TextStyle(fontSize: 15.0),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            initialCameraPosition: _kGooglePlex,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            polylines: polylineSet,
            markers: markerSet,
            circles: circlesSet,
            zoomGesturesEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;

              locatePosition();

              setState(() {
                bottomPaddingOfMap = 270.0;
              });
            },
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            bottom: 0.0,
            child: Container(
              height: 260.0,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 16.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    )
                  ]),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.0),
                    Text(
                      "Hi Tourist",
                      style: TextStyle(fontSize: 12.0),
                    ),
                    Text(
                      "Where to visit now?",
                      style:
                          TextStyle(fontSize: 20.0, fontFamily: "Brand Bold"),
                    ),
                    SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () async {
                        var res = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreen()));

                        if (res == "obtainDirection") {
                          displayDistanceContainer();
                        }
                      },
                      child: Center(
                        child: Container(
                          height: 40,
                          width: 220,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.lightBlueAccent,
                                  blurRadius: 6.0,
                                  spreadRadius: 1.5,
                                  offset: Offset(0.7, 0.7),
                                )
                              ]),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // SizedBox(width: 20.0),
                              Icon(Icons.search,
                                  color: Colors.indigoAccent.shade700),
                              // SizedBox(width: 25.0),
                              Text(
                                "Search Places",
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Brand-Regular"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Row(
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: screenWidth - 120,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(
                                  Provider.of<AppData>(context)
                                              .pickupLocation !=
                                          null
                                      ? Provider.of<AppData>(context)
                                          .pickupLocation
                                          .placeName
                                      : "Add Home",
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text("Your address",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 15.0,
                                  fontFamily: "Brand Bold",
                                )),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 10.0),
                    DividerWidget(),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Icon(
                          Icons.work,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add Work"),
                            SizedBox(
                              height: 4.0,
                            ),
                            Text(
                              "Your office address",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 15.0,
                                fontFamily: "Brand Bold",
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 200.0,
            right: 10.0,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 6.0,
                      spreadRadius: 0.5,
                      offset: Offset(
                        0.7,
                        0.7,
                      ),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black,
                  ),
                  radius: 20.0,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
                //height: MediaQuery.of(context).size.height / 3,
                child: Column(
              //mainAxisAlignment: MainAxisAlignment.center,
              //crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                DropdownExample(),
                ElevatedButton(
                  child: Text('Locate'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp2()),
                    );
                  },
                ),
              ],
            )),
          ),
          Positioned(
            bottom: 280,
            left: (screenWidth / 2) - 90,
            child: Container(
              width: 180,
              height: distanceContainerHeight,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("Distance",style: TextStyle(color: Colors.white)),
                      Text(":",style: TextStyle(color: Colors.white)),
                      Text((tripDirectionDetails!=null?tripDirectionDetails.distanceText:"0"),style: TextStyle(color: Colors.white)),

                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos =
        Provider.of<AppData>(context, listen: false).pickupLocation;
    var finalPos = Provider.of<AppData>(context, listen: false).dropOffLocation;

    var pickUpLatLng = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOffLatLng = LatLng(finalPos.latitude, finalPos.longitude);

    // showDialog(context: context, builder: (BuildContext context)=> ProgressDailog(message:"Please Wait...",));

    var details = await AssistantMethods.obtainPlaceDirectionDetails(
        pickUpLatLng, dropOffLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    print("This is encoded Points :: ");
    print(details.encodedPoints);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolyLinePointsResult =
        polylinePoints.decodePolyline(details.encodedPoints);
    pLineCoordinates.clear();
    if (decodedPolyLinePointsResult.isNotEmpty) {
      decodedPolyLinePointsResult.forEach((PointLatLng pointLatLng) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }
    polylineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        color: Colors.pink,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinates,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );
      polylineSet.add(polyline);
    });
    Marker pickUpLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "my Location"),
      position: dropOffLatLng,
      markerId: MarkerId("dropOffId"),
    );

    Circle pickUpLocCircle = Circle(
      fillColor: Colors.blueAccent,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.blueAccent,
      circleId: CircleId("pickUpId"),
    );

    Circle dropOffLocCircle = Circle(
      fillColor: Colors.deepPurple,
      center: pickUpLatLng,
      radius: 12,
      strokeWidth: 4,
      strokeColor: Colors.deepPurple,
      circleId: CircleId("dropOffId"),
    );

    setState(() {
      circlesSet.add(pickUpLocCircle);
      circlesSet.add(dropOffLocCircle);
    });

    Marker dropOffLocMarker = Marker(
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: initialPos.placeName, snippet: "DropOff Location"),
      position: pickUpLatLng,
      markerId: MarkerId("pickUpId"),
    );

    setState(() {
      markerSet.add(pickUpLocMarker);
      markerSet.add(dropOffLocMarker);
    });
  }
}

class MyApp2 extends StatelessWidget {
  final locatorService = GeoLocatorService();
  final placesService = PlacesService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        FutureProvider(create: (context) => locatorService.getLocation()),
        ProxyProvider<Position, Future<List<Place>>>(
          update: (context, position, places) {
            return (position != null)
                ? placesService.getPlaces(position.latitude, position.longitude)
                : null;
          },
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(
              "Voyage!",
              style: TextStyle(fontFamily: "Brand Bold"),
            ),
          ),
          drawer: Container(
            color: Colors.black,
            width: 260.0,
            child: Drawer(
              child: ListView(
                children: [
                  Container(
                    height: 165.0,
                    child: DrawerHeader(
                      decoration: BoxDecoration(color: Colors.white),
                      child: Row(
                        children: [
                          Image.asset(
                            "images/user_icon.png",
                            height: 55.0,
                            width: 55.0,
                          ),
                          SizedBox(
                            width: 16.0,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Profile Name",
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontFamily: "Brand-Regular"),
                              ),
                              SizedBox(
                                height: 6.0,
                              ),
                              Text("Visit Profile"),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  DividerWidget(),
                  SizedBox(
                    height: 12.0,
                  ),
                  ListTile(
                    leading: Icon(Icons.history),
                    title: Text(
                      "History",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: Text(
                      "Visit Profile",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text(
                      "About",
                      style: TextStyle(fontSize: 15.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: Search(),
        ),
      ),
    );
  }
}

class DropdownExample extends StatefulWidget {
  @override
  _DropdownExampleState createState() {
    return _DropdownExampleState();
  }
}

class _DropdownExampleState extends State<DropdownExample> {
  String _value = 'one';
  var details = {
    'one': 'atm',
    'two': 'bank',
    'three': 'bus_station',
    'four': 'car_repair',
    'five': 'gas_station',
    'six': 'gas_station',
    'seven': 'hospital',
    'eight': 'pharmacy',
    'nine': 'police',
    'ten': 'post_office',
  };
  @override
  Widget build(BuildContext context) {
    return Center(
      child: DropdownButton<String>(
        items: [
          DropdownMenuItem<String>(
            child: Text('ATM'),
            value: 'one',
          ),
          DropdownMenuItem<String>(
            child: Text('Bank'),
            value: 'two',
          ),
          DropdownMenuItem<String>(
            child: Text('Bus Station'),
            value: 'three',
          ),
          DropdownMenuItem<String>(
            child: Text('Car repair'),
            value: 'four',
          ),
          DropdownMenuItem<String>(
            child: Text('Gas Station'),
            value: 'five',
          ),
          DropdownMenuItem<String>(
            child: Text('Gas Station'),
            value: 'six',
          ),
          DropdownMenuItem<String>(
            child: Text('Hospital'),
            value: 'seven',
          ),
          DropdownMenuItem<String>(
            child: Text('Pharmacy'),
            value: 'eight',
          ),
          DropdownMenuItem<String>(
            child: Text('Police Station'),
            value: 'nine',
          ),
          DropdownMenuItem<String>(
            child: Text('Post Office'),
            value: 'ten',
          ),
        ],
        onChanged: (String value) {
          setState(() {
            _value = value;
            PlacesService.place = details[value];
          });
        },
        hint: Text('Airport'),
        value: _value,
      ),
    );
  }
}
