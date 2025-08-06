import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_lat_lon/geo_lat_lon.dart';

/// Example FireStore model
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
        'location':
            GeoFirePoint(location).data, // includes geohash and geopoint
      };
}
