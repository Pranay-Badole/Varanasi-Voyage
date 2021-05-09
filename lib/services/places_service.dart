import 'package:tourist_app/models/place.dart';
import 'package:http/http.dart' as http;
import 'package:tourist_app/configMaps.dart';

import 'dart:convert' as convert;

class PlacesService {
  static String place = 'atm';
  Future<List<Place>> getPlaces(double lat, double lng) async {
    var response = await http.get(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$lat,$lng&type=$place&rankby=distance&key=$mapKey');
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['results'] as List;
    return jsonResults.map((place) => Place.fromJson(place)).toList();
  }
}
