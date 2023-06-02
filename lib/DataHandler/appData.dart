import 'dart:ffi';

import 'package:find_a_mechanic/Models/address.dart';
import 'package:flutter/material.dart';

class AppData extends ChangeNotifier
{

   Address ?userLocation;

   void updateUserLocation(Address userAddress)
  {
    userLocation= userAddress;

    notifyListeners();

  }
}