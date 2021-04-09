import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tourist_app/AllWidgets/divider.dart';
import 'package:tourist_app/Assistants/requestAssistant.dart';
import 'package:tourist_app/DataHandler/appData.dart';
import 'package:tourist_app/Models/address.dart';
import 'package:tourist_app/Models/placePredictions.dart';
import 'package:tourist_app/configMaps.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  TextEditingController pickUpTextEditingController = TextEditingController();
  TextEditingController dropOffTextEditingController = TextEditingController();
  
  List<PlacePredictions> placePredictionList = [];
  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickupLocation.placeName ?? "";
    // String dropOff = Provider.of<AppData>(context).dropOffLocation.placeName ?? "";

    // dropOffTextEditingController.text = dropOff;
    pickUpTextEditingController.text = placeAddress;
    
    double latitude =
        Provider.of<AppData>(context).pickupLocation.latitude ?? 0.0;
    double longitude =
        Provider.of<AppData>(context).pickupLocation.longitude ?? 0.0;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(children: [
          Container(
            height: 240.0,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(0.6, 0.6),
                  blurRadius: 16.0,
                  spreadRadius: 0.6,
                )
              ],
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(50.0)),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                  left: 25.0, right: 25.0, top: 50.0, bottom: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 5.0),
                  Stack(
                    children: [
                      GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back)),
                      Center(
                        child: Text(
                          "Set Drop Off",
                          style: TextStyle(
                              fontSize: 18.0, fontFamily: "Brand Bold"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Image.asset(
                        "images/pick_icon.png",
                        height: 26.0,
                        width: 26.0,
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                          child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[40],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: TextField(
                          textAlign: TextAlign.center,
                          controller: pickUpTextEditingController,
                          decoration: InputDecoration(
                            hintText: "Pick up Location",
                            // fillColor: Colors.lightGreen,
                            filled: true,
                            contentPadding: EdgeInsets.only(
                                left: 11.0, top: 8.0, bottom: 8.0),
                          ),
                        ),
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Image.asset(
                        "images/pick_icon2.png",
                        height: 30.0,
                        width: 30.0,
                      ),
                      SizedBox(
                        width: 11.0,
                      ),
                      Flexible(
                          child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[40],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: TextField(
                            onChanged: (val) {
                              findPlace(val, latitude, longitude);
                            },
                            controller: dropOffTextEditingController,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: "Where to visit?",
                              // fillColor: Colors.grey[100],
                              filled: true,
                              contentPadding: EdgeInsets.only(
                                  left: 11.0, top: 8.0, bottom: 8.0),
                            ),
                          ),
                        ),
                      )),
                    ],
                  )
                ],
              ),
            ),
          ),
          //tile for predictions
          SizedBox(
            height: 12.0,
          ),
          (placePredictionList.length > 0)
              ? Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 2.0, horizontal: 16.0),
                  child: ListView.separated(
                    scrollDirection: Axis.vertical,
                    padding: EdgeInsets.all(0.0),
                    itemBuilder: (context, index) {
                      return PredictionTile(
                        placePredictions: placePredictionList[index],
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) =>
                        DividerWidget(),
                    itemCount: placePredictionList.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                  ),
                )
              : Container(),
        ]),
      ),
    );
  }

  void findPlace(String placeName, double lat, double long) async {
    if (placeName.length > 1) {
      String autoCompleteUrl =
          "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&language=en&components=country:in&origin=$lat,$long&location=$lat,$long&radius=20000&sessiontoken=1234567890";

      var res = await RequestAssistant.getRequest(Uri.parse(autoCompleteUrl));

      if (res == "failed") {
        return;
      }
      // print("Places Predictions Response :: ");
      // print(res);

      if (res["status"] == "OK") {
        var predictions = res["predictions"];
        var placesList = (predictions as List)
            .map((e) => PlacePredictions.fromJson(e))
            .toList();

        setState(() {
          placePredictionList = placesList;
        });
      }
    }
  }
}

class PredictionTile extends StatelessWidget {
  final PlacePredictions placePredictions;

  const PredictionTile({Key key, this.placePredictions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return FlatButton(
      padding: EdgeInsets.all(0.0),
      onPressed: () {
        // print("Pressed");
        getPlaceAddressDetails(placePredictions.place_id, context);
      },
      child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
          child: Column(
            children: [
              SizedBox(
                width: 10.0,
              ),
              Row(
                children: [
                  Icon(Icons.add_location_alt_outlined),
                  SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.0),
                        Text(
                          placePredictions.main_text,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 17.0),
                        ),
                        SizedBox(height: 3.0),
                        Text(placePredictions.secondary_text,
                            // overflow: TextOverflow.clip,
                            style: TextStyle(
                              fontSize: 15.0,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                // child: Container(color: Colors.greenAccent,),
                height: 10.0,
              ),
            ],
          )),
    );
  }

  void getPlaceAddressDetails(String placeId, context) async {
    // showDialog(context: context, builder: (BuildContext context) => ProgressDialog(message : "Setting Dropoff, Please Wait..."));
    String placeDetailsUrl =
        "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var res = await RequestAssistant.getRequest(Uri.parse(placeDetailsUrl));
    if (res == "failed") {
      return;
    }
    if (res["status"] == "OK") {
      Address address = Address();
      address.placeName = res["result"]["name"];
      address.placeId = placeId;
      address.latitude = res["result"]["geometry"]["location"]["lat"];
      address.longitude = res["result"]["geometry"]["location"]["lng"];
      Provider.of<AppData>(context, listen: false)
          .updateDropOffLocationAddress(address);
      print("This is drop Off :: ");
      print(address.placeName);

      Navigator.pop(context,"obtainDirection");
    }
  }
}
