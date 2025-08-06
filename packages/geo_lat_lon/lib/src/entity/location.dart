import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_lat_lon/src/entity/geo.dart';

/// An entity of Cloud Firestore location document.
class Location {
  Location({required this.geo, required this.name});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    geo: Geo.fromJson(json['geo'] as Map<String, dynamic>),
    name: json['name'] as String,
  );

  factory Location.fromDocumentSnapshot(DocumentSnapshot documentSnapshot) =>
      Location.fromJson(documentSnapshot.data()! as Map<String, dynamic>);

  final Geo geo;
  final String name;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'geo': geo.toJson(),
    'name': name,
  };
}
