import 'package:flutter/material.dart';
import 'package:geo_lat_lon/geo_lat_lon.dart';

import 'delete_location.dart';
import 'set_location.dart';

/// AlertDialog widget to add location data to Cloud Firestore.
class SetOrDeleteLocationDialog extends StatelessWidget {
  const SetOrDeleteLocationDialog({
    super.key,
    required this.id,
    required this.name,
    required this.geoLatLon,
  });

  final String id;
  final String name;
  final GeoLatLon geoLatLon;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(
        child: Text('Enter location data'),
      ),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => SetLocationDialog(
                id: id,
                name: name,
                geoLatLon: geoLatLon,
              ),
            ),
            child: const Text('set location'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => DeleteLocationDialog(
                id: id,
                name: name,
                geoLatLon: geoLatLon,
              ),
            ),
            child: const Text('delete location'),
          ),
        ],
      ),
    );
  }
}
