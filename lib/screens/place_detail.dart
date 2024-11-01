import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlaceDetailScreen extends StatelessWidget {
  const PlaceDetailScreen({super.key, required this.place});

  final Place place;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(place.title),
        ),
        body: Stack(
          children: [
            //? starting with bottom most widget       (bottom most should be written first)

            Image.file(
              place.image,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyMap(place: place),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 70,
                      child: ClipOval(
                        child: SizedBox(
                          width: 140,
                          height: 140,
                          child: AbsorbPointer(
                            // Add this to prevent map interaction
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  place.location.latitude,
                                  place.location.longitude,
                                ),
                                initialZoom: 13.0,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.google.com/vt/lyrs=m&hl={hl}&x={x}&y={y}&z={z}',
                                  additionalOptions: const {'hl': 'en'},
                                  subdomains: const [
                                    'mt0',
                                    'mt1',
                                    'mt2',
                                    'mt3'
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                        place.location.latitude,
                                        place.location.longitude,
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        size: 25,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          const Color.fromARGB(157, 0, 0, 0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Text(
                      place.location.address,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}




//  FlutterMap(
//                           options: MapOptions(
//                             interactionOptions:
//                                 InteractionOptions(flags: InteractiveFlag.none),
//                             initialCenter: LatLng(place.location.latitude,
//                                 place.location.longitude),
//                             initialZoom: 13.0,
//                           ),
//                           children: [
//                             TileLayer(
//                               urlTemplate:
//                                   'https://{s}.google.com/vt/lyrs=m&hl={hl}&x={x}&y={y}&z={z}',
//                               additionalOptions: const {'hl': 'en'},
//                               subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
//                             ),
//                             MarkerLayer(
//                               markers: [
//                                 Marker(
//                                   point: LatLng(place.location.latitude,
//                                       place.location.longitude),
//                                   child: const Icon(
//                                     Icons.location_on,
//                                     size: 25,
//                                     color: Colors.blue,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),