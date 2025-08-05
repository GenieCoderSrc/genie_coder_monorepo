import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geo_lat_lon/src/converter/i_converter/i_fire_store_model_converter.dart';

/// A reusable generic function to get a typed collection reference.
CollectionReference<T> typedCollectionReference<T>({
  String? path,
  required IFireStoreModelConverter<T> converter,
}) {
  return FirebaseFirestore.instance
      .collection(path ?? 'locations')
      .withConverter<T>(
        fromFirestore: (snapshot, _) => converter.fromFireStore(snapshot),
        toFirestore: (value, _) => converter.toFireStore(value),
      );
}
