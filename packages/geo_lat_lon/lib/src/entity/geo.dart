import 'package:cloud_firestore/cloud_firestore.dart';

/// An entity of `geo` field of Cloud Firestore location document.
class Geo {
  Geo({required this.geohash, required this.geopoint});

  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
    geohash: json['geohash'] as String,
    geopoint: json['geopoint'] as GeoPoint,
  );

  final String geohash;
  final GeoPoint geopoint;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'geohash': geohash,
    'geopoint': geopoint,
  };
}
