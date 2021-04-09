import 'package:flutter/cupertino.dart';
import 'package:tourist_app/Models/address.dart';

class AppData extends ChangeNotifier {
  
  Address pickupLocation, dropOffLocation;
  void updatePickupLocationAddress(Address pickupAddress) {
    pickupLocation = pickupAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Address dropOffAddress) {
    dropOffLocation = dropOffAddress;
    notifyListeners();
  }
}
