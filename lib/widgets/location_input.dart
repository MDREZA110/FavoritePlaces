import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo; // Alias for geocoding
import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/widgets/pick_map.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({super.key, required this.onSelectPlace});

  final Function onSelectPlace;

  @override
  State<LocationInput> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  late final MapController mapController;
  var _isGettingLocation = false;

  @override
  void initState() {
    mapController = MapController();
    super.initState();
  }

  Future<List> getLocationAddress(double latitude, double longitude) async {
    List<geo.Placemark> placemark =
        await geo.placemarkFromCoordinates(latitude, longitude);
    return placemark;
  }

  Future<void> _savePlace(double latitude, double longitude) async {
    final addressData = await getLocationAddress(latitude, longitude);
    final String street = addressData[0].street;
    final String postalcode = addressData[0].postalCode;
    final String locality = addressData[0].locality;
    final String country = addressData[0].country;
    final String address = '$street, $postalcode, $locality, $country';

    setState(() {
      _pickedLocation = PlaceLocation(
        latitude: latitude,
        longitude: longitude,
        address: address,
      );
      _isGettingLocation = false;
    });

    widget.onSelectPlace(_pickedLocation!.latitude, _pickedLocation!.longitude);
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    setState(() {
      _isGettingLocation = true;
    });

    locationData = await location.getLocation();
    final lat = locationData.latitude;
    final lng = locationData.longitude;

    if (lat == null || lng == null) {
      return;
    }

    _savePlace(lat, lng);
  }

  Future<void> _selectOnMap() async {
    final pickedLocation = await Navigator.of(context).push<LatLng>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => const PickMap(
          isSelecting: true,
        ),
      ),
    );

    if (pickedLocation == null) {
      return;
    }

    _savePlace(pickedLocation.latitude, pickedLocation.longitude);
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No location chosen',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.surface,
          ),
    );

    if (_pickedLocation != null) {
      previewContent = FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter:
              LatLng(_pickedLocation!.latitude, _pickedLocation!.longitude),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://{s}.google.com/vt/lyrs=m&hl={hl}&x={x}&y={y}&z={z}',
            additionalOptions: const {'hl': 'en'},
            subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(
                    _pickedLocation!.latitude, _pickedLocation!.longitude),
                child: const Icon(
                  Icons.location_on,
                  size: 25,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    }

    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ),
          ),
          child: previewContent,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location'),
              onPressed: _getCurrentLocation,
            ),
            TextButton.icon(
              icon: const Icon(Icons.map),
              label: const Text('Select on Map'),
              onPressed: _selectOnMap,
            ),
          ],
        ),
      ],
    );
  }
}

//^|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:location/location.dart';

// class LocationInput extends StatefulWidget {
//   const LocationInput({super.key, required this.onSelectLocation});

//   final void Function(LocationData image) onSelectLocation;

//   @override
//   State<LocationInput> createState() => _LocationInputState();
// }

// class _LocationInputState extends State<LocationInput> {
//   Location? pickedLocation;
//   var isGettingLocation = false;
//   LocationData? _pickedLocation;

//   void _getCurrentLocation() async {
//     Location location = Location();

//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     // Check if location services are enabled
//     serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         return;
//       }
//     }

//     permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         return;
//       }
//     }

//     setState(() {
//       isGettingLocation = true;
//     });

//     final locationData = await location.getLocation();

//     setState(() {
//       isGettingLocation = false;
//       _pickedLocation = locationData;
//     });

//     widget.onSelectLocation(_pickedLocation!);
//   }

//   @override
//   Widget build(BuildContext context) {
//     Widget content = const Text("No location chosen");

//     if (isGettingLocation) {
//       content = const CircularProgressIndicator();
//     } else if (_pickedLocation != null) {
//       content = FlutterMap(
//         options: MapOptions(
//           initialCenter: LatLng(
//             _pickedLocation!.latitude!,
//             _pickedLocation!.longitude!,
//           ),
//           initialZoom: 15.0,
//         ),
//         children: [
//           TileLayer(
//             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
//             subdomains: const ['a', 'b', 'c'],
//           ),
//           MarkerLayer(
//             markers: [
//               Marker(
//                 point: LatLng(
//                   _pickedLocation!.latitude!,
//                   _pickedLocation!.longitude!,
//                 ),
//                 child: const Icon(
//                   Icons.location_on,
//                   color: Colors.red,
//                   size: 40,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       );
//     }

//     // Widget content;
//     // if (isGettingLocation) {
//     //   content = const Center(child: CircularProgressIndicator());
//     // }
//     // if (_pickedLocation == null) {
//     //   content = TextButton.icon(
//     //     icon: const Icon(Icons.location_pin),
//     //     label: const Text('No location Selected'),
//     //     onPressed: () {},
//     //   );
//     // } else {
//     //   content = Text(_pickedLocation!.latitude.toString());
//     // }

//     if (isGettingLocation) {}

//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           height: 170,
//           decoration: BoxDecoration(
//             border: Border.all(
//                 width: 1,
//                 color: Theme.of(context).colorScheme.primary.withOpacity(0.2)),
//           ),
//           alignment: Alignment.center, //&  alignment of child
//           child: content,
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             TextButton.icon(
//               icon: const Icon(Icons.location_on),
//               label: const Text('Get Current Location'),
//               onPressed: _getCurrentLocation,
//             ),
//             TextButton.icon(
//               icon: const Icon(Icons.map),
//               label: const Text('Select on Map'),
//               onPressed: () {},
//             )
//           ],
//         )
//       ],
//     );
//   }
// }


// /////////////////////////
// // import 'package:flutter/material.dart';
// // import 'package:flutter_map/flutter_map.dart';
// // import 'package:latlong2/latlong.dart';
// // import 'package:geolocator/geolocator.dart';

// // class LocationInput extends StatefulWidget {
// //   const LocationInput({super.key, required this.onSelectLocation});

// //   final void Function(Position image) onSelectLocation;

// //   @override
// //   State<LocationInput> createState() => _LocationInputState();
// // }

// // class _LocationInputState extends State<LocationInput> {
// //   Position? _pickedLocation;
// //   var isGettingLocation = false;

// //   void _getCurrentLocation() async {
// //     setState(() {
// //       isGettingLocation = true;
// //     });

// //     // Check for location services enabled
// //     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
// //     if (!serviceEnabled) {
// //       setState(() {
// //         isGettingLocation = false;
// //       });
// //       return Future.error('Location services are disabled.');
// //     }

// //     // Check for location permissions
// //     LocationPermission permission = await Geolocator.checkPermission();
// //     if (permission == LocationPermission.denied) {
// //       permission = await Geolocator.requestPermission();
// //       if (permission == LocationPermission.denied) {
// //         setState(() {
// //           isGettingLocation = false;
// //         });
// //         return Future.error('Location permissions are denied.');
// //       }
// //     }

// //     if (permission == LocationPermission.deniedForever) {
// //       setState(() {
// //         isGettingLocation = false;
// //       });
// //       return Future.error(
// //           'Location permissions are permanently denied, we cannot request permissions.');
// //     }
// //     LocationSettings locationSettings = const LocationSettings(
// //       accuracy: LocationAccuracy.high, // High accuracy
// //     );
// //     // Get the current position
// //     Position locationData = await Geolocator.getCurrentPosition(
// //       locationSettings: locationSettings,
// //     );

// //     setState(() {
// //       isGettingLocation = false;
// //       _pickedLocation = locationData;
// //     });

// //     widget.onSelectLocation(_pickedLocation!);
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     Widget content = const Text("No location chosen");

// //     if (isGettingLocation) {
// //       content = const CircularProgressIndicator();
// //     } else if (_pickedLocation != null) {
// //       content = FlutterMap(
// //         options: MapOptions(
// //           initialCenter: LatLng(
// //             _pickedLocation!.latitude,
// //             _pickedLocation!.longitude,
// //           ),
// //           initialZoom: 15.0,
// //         ),
// //         children: [
// //           TileLayer(
// //             urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
// //             subdomains: const ['a', 'b', 'c'],
// //           ),
// //           MarkerLayer(
// //             markers: [
// //               Marker(
// //                 point: LatLng(
// //                   _pickedLocation!.latitude,
// //                   _pickedLocation!.longitude,
// //                 ),
// //                 child: const Icon(
// //                   Icons.location_on,
// //                   color: Colors.red,
// //                   size: 40,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ],
// //       );
// //     }

// //     return Column(
// //       children: [
// //         Container(
// //           width: double.infinity,
// //           height: 170,
// //           decoration: BoxDecoration(
// //             border: Border.all(
// //               width: 1,
// //               color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
// //             ),
// //           ),
// //           alignment: Alignment.center,
// //           child: content,
// //         ),
// //         Row(
// //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //           children: [
// //             TextButton.icon(
// //               icon: const Icon(Icons.location_on),
// //               label: const Text('Get Current Location'),
// //               onPressed: _getCurrentLocation,
// //             ),
// //             TextButton.icon(
// //               icon: const Icon(Icons.map),
// //               label: const Text('Select on Map'),
// //               onPressed: () {},
// //             ),
// //           ],
// //         ),
// //       ],
// //     );
// //   }
// // }




