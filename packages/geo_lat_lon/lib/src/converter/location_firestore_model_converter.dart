import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_lat_lon/geo_lat_lon.dart';

class LocationFireStoreModelConverter
    extends IFireStoreModelConverter<Location> {
  @override
  Location fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Location.fromDocumentSnapshot(snapshot);
  }

  @override
  Map<String, dynamic> toFireStore(Location model) {
    return model.toJson();
  }
}
