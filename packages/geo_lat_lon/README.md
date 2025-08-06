# 📦 geo_lat_lon

`geo_lat_lon` is a modern Dart/Flutter package for performing geospatial queries on Cloud Firestore using geohashes. It is a fork of the `geoflutterfire_plus` package, with updated code and design improvements to support the latest versions of Flutter and Firestore SDKs.

---

## 🚀 Features

* Add, update, and delete documents with location data
* Perform radius-based geo queries
* Subscribe to real-time location updates
* Calculate geohash precision automatically
* Client-side filtering for precise results
* Supports Firestore typed converters

---

## 🧱 Installation

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  geo_lat_lon: <latest_version>
```

---

## 🧱 Structure

### ✅ `GeoCollectionReference<T>`

An enhanced wrapper around Firestore’s `CollectionReference<T>` that enables querying by geohash and location.

* `add(T data)`
* `set(...)`
* `updatePoint(...)`
* `delete(...)`
* `fetchWithin(...)`
* `subscribeWithin(...)`

### 📍 `GeoFirePoint`

Encapsulates a Firestore `GeoPoint` and provides:

* `geohash`
* `neighbors`
* `distanceBetweenInKm(...)`
* `data` → to be saved into Firestore

### 📄 `GeoDocumentSnapshot<T>`

A wrapper for Firestore `DocumentSnapshot` with calculated distance from a center point.

---

## 🔁 Real-time Query Example

```dart
final geoRef = GeoCollectionReference<ShopModel>(shopCollection);

geoRef.subscribeWithin(
  center: GeoFirePoint(GeoPoint(23.81, 90.41)),
  radiusInKm: 5.0,
  field: 'location',
  geopointFrom: (shop) => shop.location,
).listen((snapshots) {
  for (final doc in snapshots) {
    print(doc.data());
  }
});
```

---


## 📁 Firestore Document Structure

```json
{
  "location": {
    "geopoint": GeoPoint(23.8103, 90.4125),
    "geohash": "w21zv0h9"
  },
  "name": "Shop 01",
  "isVisible": true
}
```



## 🧑‍💻 Example Usage

### Define Your Model

```dart
class Location {
  final Geo geo;
  final String name;
  final bool isVisible;

  Location({required this.geo, required this.name, required this.isVisible});

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        geo: Geo.fromJson(json['geo']),
        name: json['name'],
        isVisible: json['isVisible'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'geo': geo.toJson(),
        'name': name,
        'isVisible': isVisible,
      };

  factory Location.fromDocumentSnapshot(DocumentSnapshot doc) =>
      Location.fromJson(doc.data() as Map<String, dynamic>);
}

class Geo {
  final String geohash;
  final GeoPoint geopoint;

  Geo({required this.geohash, required this.geopoint});

  factory Geo.fromJson(Map<String, dynamic> json) => Geo(
        geohash: json['geohash'],
        geopoint: json['geopoint'],
      );

  Map<String, dynamic> toJson() => {
        'geohash': geohash,
        'geopoint': geopoint,
      };
}
```

### Define Converter

```dart
class LocationFireStoreModelConverter extends IFireStoreModelConverter<Location> {
  @override
  Location fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Location.fromDocumentSnapshot(snapshot);
  }

  @override
  Map<String, dynamic> toFireStore(Location model) {
    return model.toJson();
  }
}
```

### Create a Typed Collection Reference

```dart
final locationCollection = typedCollectionReference<Location>(
  path: 'locations',
  converter: LocationFireStoreModelConverter(),
);
```

### Subscribe to Geo Query

```dart
final geoRef = GeoCollectionReference<Location>(locationCollection);

geoRef.subscribeWithin(
  center: GeoFirePoint(GeoPoint(23.81, 90.41)),
  radiusInKm: 5.0,
  field: 'geo',
  geopointFrom: (location) => location.geo.geopoint,
).listen((snapshots) {
  for (final doc in snapshots) {
    print(doc.data().name);
  }
});
```

---

## 📁 Firestore Document Structure

```json
{
  "geo": {
    "geopoint": GeoPoint(23.8103, 90.4125),
    "geohash": "w21zv0h9"
  }
}
```

Use the `GeoFirePoint` class to generate this data consistently.

```dart
final point = GeoFirePoint(GeoPoint(23.8103, 90.4125));
final data = point.data; // {'geopoint': ..., 'geohash': ...}
```

---

## 📀 How It Works

1. 🔒 **Geohash Encoding**: Converts lat/lng to a geohash string.
2. 📶 **Neighboring Hashes**: Queries current and surrounding geohash cells.
3. 🔍 **Range Querying**: Performs Firestore queries with `startAt`/`endAt` for geohash ranges.
4. 🧠 **Client-side Filtering**: Optionally filters results strictly based on radius.
5. 📊 **Sorting**: Results are sorted by proximity.

---

## ⚠️ Notes

* Always use `GeoFirePoint` when saving or updating geo fields.
* Use `strictMode: true` when you want distance-accurate filtering.
* This package requires Firestore indexing on the geohash field
* Avoid radius smaller than 0.5 km for edge-case accuracy
* Client-side sorting is preferred over Firestore `orderBy`

---

## 🔗 Credits

Forked and evolved from [geoflutterfire_plus](https://pub.dev/packages/geoflutterfire_plus) with support for latest Dart, Flutter, and Firestore SDK.

---

## 📚 References

* [Geohash Wikipedia](https://en.wikipedia.org/wiki/Geohash)
* [Firestore Queries](https://firebase.google.com/docs/firestore/query-data/queries)

---

## 👨‍💼 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

Made with ❤️ by the `geo_lat_lon` team.
