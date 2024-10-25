// ignore: depend_on_referenced_packages
import 'dart:io';

import 'package:location/location.dart';
import 'package:riverpod/riverpod.dart';

import 'package:favorite_places/models/place.dart';

class UserPlacesNotifire extends StateNotifier<List<Place>> {
  UserPlacesNotifire() : super(const []);

  void addPlace(String title, File image, LocationData locationData) {
    final newPlace =
        Place(title: title, image: image, locationData: locationData);
    state = [newPlace, ...state];
  }
}

final userPlacesNotifire =
    StateNotifierProvider<UserPlacesNotifire, List<Place>>(
  (ref) => UserPlacesNotifire(),
);
