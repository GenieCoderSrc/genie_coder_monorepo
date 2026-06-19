# 📦 Changelog - geo_lat_lon

## 0.0.6

### Jun 15, 2026

### ✨ Updated

- Updated `cloud_firestore: ^6.5.0`

All notable changes to the `geo_lat_lon` package will be documented in this file.

---

## 0.0.5

### Sep 8, 2025

### ✨ Updated

- Updated `cloud_firestore` to 6.0.1

## 0.0.4

### Aug 22, 2025

### ✨ Updated

- Updated Dart sdk to 3.9.0
- Removed `flutter_lints` Dependency
- Removed `mockito` Dependency

## 0.0.3

### Aug 6, 2025

### ✅Refactored

* ✅ Renamed `GeoLatLon` to `GeoFirePoint`.

## 0.0.2

### Aug 5, 2025

### ✅Updated

* ✅ Updated the Example code with `GoogleMapExample`.
* ✅ Updated the [README.md](README.md) with more Example codes.

## 0.0.1

### Aug 5, 2025

### 🎉 Initial Release

* ✅ Introduced `GeoCollectionReference<T>` for Firestore geo queries.
* ✅ Added support for radius-based filtering with `fetchWithin` and `subscribeWithin`.
* ✅ Implemented `GeoFirePoint` class to wrap `GeoPoint` and generate geohashes.
* ✅ Added `GeoDocumentSnapshot<T>` for distance-aware querying.
* ✅ Provided `strictMode` for accurate client-side distance filtering.
* ✅ Utility support for calculating geohash neighbors.
* ✅ `queryBuilder` pattern supported for custom query injection.
* ✅ Example usage for stream-based and static data fetching.

---

## Upcoming

### 🚧 Planned Improvements

* 🔄 Add `updateManyPoints()` utility for batch geo updates.
* 📊 Add visual demo integration with Google Maps.
* 🔧 Firestore index migration script generation.
* 🧪 Increase test coverage and mocking of Firestore interactions.
* 📘 Add tutorial documentation and integration with example app.

---

Maintained with ❤️ by the geo_lat_lon team.
