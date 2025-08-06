import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_lat_lon/geo_lat_lon.dart';

import 'entity/shop.dart';

Future<void> addModelWithLocation() async {
  final collection =
      FirebaseFirestore.instance.collection('shops').withConverter<Shop>(
            fromFirestore: (snapshot, _) => Shop.fromJson(snapshot.data()!),
            toFirestore: (shop, _) => shop.toJson(),
          );

  final geoRef = GeoCollectionReference<Shop>(collection);

  // Add a shop
  final shop = Shop(
    name: 'Coffee Zone',
    location: GeoPoint(23.8103, 90.4125),
  );
  await geoRef.add(shop);
}
