import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/place.dart';

class MyMap extends StatefulWidget {
  const MyMap({super.key, required this.place});

  final Place place;

  @override
  State<MyMap> createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.place.title)),
      body: FlutterMap(
        options: MapOptions(
          //interactionOptions: InteractionOptions(flags: InteractiveFlag.none),
          initialCenter: LatLng(
              widget.place.location.latitude, widget.place.location.longitude),
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
                point: LatLng(widget.place.location.latitude,
                    widget.place.location.longitude),
                child: const Icon(
                  Icons.location_on,
                  size: 33,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
