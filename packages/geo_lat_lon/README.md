# 📦 geo_lat_lon

`geo_lat_lon` is a Dart/Flutter package designed to simplify **geospatial querying** in **Cloud Firestore** using geohashes. It enhances Firestore's `CollectionReference` with features that allow you to:

* 🌐 Add, update, and delete documents with location data
* 🔍 Perform radius-based geo queries
* 📡 Subscribe to location-based updates in real-time
* 📏 Filter results strictly within a geographical radius
* ⚙️ Automatically calculate geohash precision and bounding regions

---

## 🚀 Installation

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

### 📍 `GeoLatLon`

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
  center: GeoLatLon(GeoPoint(23.81, 90.41)),
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

## 📐 How It Works

1. 🔒 **Geohash Encoding**: Converts lat/lng to a geohash string.
2. 📶 **Neighboring Hashes**: Queries current and surrounding geohash cells.
3. 🔍 **Range Querying**: Performs Firestore queries with `startAt`/`endAt` for geohash ranges.
4. 🧠 **Client-side Filtering**: Optionally filters results strictly based on radius.
5. 📊 **Sorting**: Results are sorted by proximity.

---

## 📄 Firestore Document Format

```json
{
  "location": {
    "geopoint": GeoPoint(23.8103, 90.4125),
    "geohash": "w21zv0h9"
  }
}
```

Use the `GeoLatLon` class to generate this data consistently.

```dart
final point = GeoLatLon(GeoPoint(23.8103, 90.4125));
final data = point.data; // {'geopoint': ..., 'geohash': ...}
```

---

## ⚙️ Best Practices

* Always use `GeoLatLon` when saving or updating geo fields.
* Use `strictMode: true` when you want distance-accurate filtering.
* Ensure your Firestore index supports sorting on geohash.
* Avoid radii smaller than 0.5 km to reduce missed edge cases.

---

## 📚 References

* [Geohash Wikipedia](https://en.wikipedia.org/wiki/Geohash)
* [Firestore Queries](https://firebase.google.com/docs/firestore/query-data/queries)

---

## 👨‍💻 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

---

Made with ❤️ by the `geo_lat_lon` team.
