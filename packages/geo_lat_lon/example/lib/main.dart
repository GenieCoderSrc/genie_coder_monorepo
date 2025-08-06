import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geo_lat_lon/geo_lat_lon.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';

import 'add_location.dart';
import 'firebase_options.dart';
import 'set_or_delete_location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
        ),
      ),
      home: const GoogleMapExample(),
      // See using with converter example by removing comment below:
      // home: const WithConverterExample(),
      // See adding custom queries example by removing comment below:
      // home: const AdditionalQueryExample(),
      // home: const GeoFlutterFire2Example(),
    );
  }
}

/// Tokyo Station location.
const _tokyoStation = LatLng(35.681236, 139.767125);

final _collectionReference = FirebaseFirestore.instance.collection('locations');

class _GeoQueryCondition {
  _GeoQueryCondition({required this.radiusInKm, required this.cameraPosition});

  final double radiusInKm;
  final CameraPosition cameraPosition;
}

class GoogleMapExample extends StatefulWidget {
  const GoogleMapExample({super.key});

  @override
  GoogleMapExampleState createState() => GoogleMapExampleState();
}

class GoogleMapExampleState extends State<GoogleMapExample> {
  Set<Marker> _markers = {};
  final _geoQueryCondition = BehaviorSubject<_GeoQueryCondition>.seeded(
    _GeoQueryCondition(
      radiusInKm: _initialRadiusInKm,
      cameraPosition: _initialCameraPosition,
    ),
  );

  late final Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream =
      _geoQueryCondition.switchMap((geoQueryCondition) {
    final centerPoint = GeoFirePoint(
      GeoPoint(
        geoQueryCondition.cameraPosition.target.latitude,
        geoQueryCondition.cameraPosition.target.longitude,
      ),
    );
    return GeoCollectionReference(_collectionReference).subscribeWithin(
      center: centerPoint,
      radiusInKm: geoQueryCondition.radiusInKm,
      field: 'geo',
      geopointFrom: (data) =>
          (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
      strictMode: true,
    );
  });

  void _updateMarkersByDocumentSnapshots(
      List<DocumentSnapshot<Map<String, dynamic>>> docs) {
    final markers = <Marker>{};
    for (final ds in docs) {
      final data = ds.data();
      if (data == null) continue;
      final geo = data['geo'] as Map<String, dynamic>;
      final point = geo['geopoint'] as GeoPoint;
      markers.add(
        Marker(
          markerId: MarkerId(ds.id),
          position: LatLng(point.latitude, point.longitude),
          infoWindow: InfoWindow(title: data['name']),
          onTap: () => showDialog<void>(
            context: context,
            builder: (context) => SetOrDeleteLocationDialog(
              id: ds.id,
              name: data['name'],
              geoFirePoint: GeoFirePoint(point),
            ),
          ),
        ),
      );
    }
    setState(() => _markers = markers);
  }

  double get _radiusInKm => _geoQueryCondition.value.radiusInKm;

  CameraPosition get _cameraPosition => _geoQueryCondition.value.cameraPosition;

  static const double _initialRadiusInKm = 1;
  static const double _initialZoom = 14;
  static final _initialTarget = _tokyoStation;
  static final _initialCameraPosition =
      CameraPosition(target: _initialTarget, zoom: _initialZoom);

  @override
  void dispose() {
    _geoQueryCondition.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (_) =>
                _stream.listen(_updateMarkersByDocumentSnapshots),
            markers: _markers,
            circles: {
              Circle(
                circleId: const CircleId('radius'),
                center: _cameraPosition.target,
                radius: _radiusInKm * 1000,
                fillColor: Colors.black12,
                strokeWidth: 0,
              ),
            },
            onCameraMove: (pos) => _geoQueryCondition.add(
              _GeoQueryCondition(radiusInKm: _radiusInKm, cameraPosition: pos),
            ),
            onLongPress: (latLng) => showDialog<void>(
              context: context,
              builder: (context) => AddLocationDialog(latLng: latLng),
            ),
          ),
          _buildDebugWindow(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (context) => const AddLocationDialog(),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDebugWindow() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 64, left: 16, right: 16),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Debug window',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Detected: ${_markers.length}',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Text('Radius: ${_radiusInKm.toStringAsFixed(1)} km',
              style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Slider(
            value: _radiusInKm,
            min: 1,
            max: 100,
            divisions: 99,
            label: _radiusInKm.toStringAsFixed(1),
            onChanged: (value) => _geoQueryCondition.add(
              _GeoQueryCondition(
                  radiusInKm: value, cameraPosition: _cameraPosition),
            ),
          ),
        ],
      ),
    );
  }
}
