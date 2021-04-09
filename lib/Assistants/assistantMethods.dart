import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tourist_app/Assistants/requestAssistant.dart';
import 'package:tourist_app/DataHandler/appData.dart';
import 'package:tourist_app/Models/address.dart';
import 'package:tourist_app/Models/directDetails.dart';
import 'package:tourist_app/configMaps.dart';

class AssistantMethods {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = "";
    String s1, s2, s3 = '', s4 = '';
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    var response = await RequestAssistant.getRequest(Uri.parse(url));

    if (response != "failed") {
      // placeAddress = response["results"][0]["formatted_address"];
      s1 = response["results"][0]["address_components"][0]["long_name"];
      s2 = response["results"][0]["address_components"][1]["long_name"];
      s3 = response["results"][0]["address_components"][2]["long_name"];
      s4 = response["results"][0]["address_components"][3]["long_name"];

      placeAddress = s1 + ", " + s2 + ", " + s3 + ", " + s4;

      Address userPickupAddress = new Address();
      userPickupAddress.longitude = position.longitude;
      userPickupAddress.latitude = position.latitude;
      userPickupAddress.placeName = placeAddress;
      // print(userPickupAddress.latitude);
      // print(userPickupAddress.longitude);
      Provider.of<AppData>(context, listen: false)
          .updatePickupLocationAddress(userPickupAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetails> obtainPlaceDirectionDetails(
      LatLng initialPosition, LatLng finalPosition) async {
    String directionUrl =
        "https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=$mapKey";

    var res = await RequestAssistant.getRequest(Uri.parse(directionUrl));
    if (res == "failed") {
      return null;
    }
    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.encodedPoints = res["routes"][0]["overview_polyline"]["points"];
    
    directionDetails.distanceText = res["routes"][0]["legs"][0]["distance"]["text"];
    directionDetails.distanceValue = res["routes"][0]["legs"][0]["distance"]["value"];

    directionDetails.durationText = res["routes"][0]["legs"][0]["duration"]["text"];
    directionDetails.durationValue = res["routes"][0]["legs"][0]["duration"]["value"];

    return directionDetails;
  }
}
