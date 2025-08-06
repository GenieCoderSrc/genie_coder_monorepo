import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_lat_lon/geo_lat_lon.dart';

import 'entity/shop.dart';

void listenNearByLocation() async {
  final collection =
      FirebaseFirestore.instance.collection('shops').withConverter<Shop>(
            fromFirestore: (snapshot, _) => Shop.fromJson(snapshot.data()!),
            toFirestore: (shop, _) => shop.toJson(),
          );

  final geoRef = GeoCollectionReference<Shop>(collection);

  // Listen to shops within 5km radius
  geoRef
      .subscribeWithin(
    center: GeoFirePoint(GeoPoint(23.8103, 90.4125)),
    radiusInKm: 5.0,
    field: 'location',
    geopointFrom: (shop) => shop.location,
  )
      .listen((docs) {
    for (final doc in docs) {
      print('Nearby shop: ${doc.data()?.name}');
    }
  });
}
