import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_lat_lon/geo_lat_lon.dart';

void main() async {
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

  // Listen to shops within 5km radius
  geoRef
      .subscribeWithin(
    center: GeoLatLon(GeoPoint(23.8103, 90.4125)),
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

/// Example Firestore model
class Shop {
  const Shop({required this.name, required this.location});

  final String name;
  final GeoPoint location;

  factory Shop.fromJson(Map<String, dynamic> json) => Shop(
        name: json['name'] as String,
        location: (json['location']['geopoint']) as GeoPoint,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'location': GeoLatLon(location).data, // includes geohash and geopoint
      };
}
