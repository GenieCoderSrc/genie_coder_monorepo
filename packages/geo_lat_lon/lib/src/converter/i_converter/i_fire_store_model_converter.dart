import 'package:cloud_firestore/cloud_firestore.dart';

/// Abstract converter for FireStore to decouple data model logic.
abstract class IFireStoreModelConverter<T> {
  T fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot);

  Map<String, dynamic> toFireStore(T model);
}
