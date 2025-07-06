# Changelog

All notable changes to this project will be documented in this file.

## 0.0.4 – Jul 6, 2025

### ✨ Added

- `typedef`s for typed callbacks:
  - `ImageDataCallback`
  - `VoidImageDataCallback`
  - `WidgetImageDataCallback`


## 0.0.3 – Jul 6, 2025

### ✨ Added

- `AppImagePicker` widget with `ImagePickerCubit` state management.
- `AvatarImageViewer` with:
  - Circular or rectangular image display.
  - Editable icon overlay with customizable position.
  - Double-tap to open `FullScreenImageViewer`.
- `FullScreenImageViewer`:
  - Supports zoom, pan, double-tap zoom, swipe-to-dismiss.
  - Supports image from `File`, `Uint8List`, or network/asset source.
  - Download support for viewing images.
- `AvatarImagePicker` enhancements:
  - Accepts `radius`, `heroTag`, `isCircleAvatar`, `onTapEdit`, `editIcon`, etc.
  - Fully integrated with `AppImagePicker` for image state propagation.
- `AvatarStyleConstants` for centralized avatar size and layout presets.

### ✅ Updated

- Refactored `AppImagePicker` for flexibility and better builder usage.
- Integrated `AppImagePicker` with image cropping and compression via cubit.
- Improved error handling, null safety, and loading state visuals.
- Fully integrated `ImagePickerCubit` with `flutter_bloc` and `get_it`.

### 🛠️ Refactored

- Modularized avatar viewer structure.
- Separated image preview logic into reusable components.
- Clarified naming and responsibilities across image components.

---

## 0.0.2+1 – Jun 30, 2025

- Replaced `ImagePickerCubit` in view model.

## 0.0.2 – Jun 24, 2025

- Fixed error in `compress_image.dart` file.

## 0.0.1 – Apr 29, 2025

- Added `AvatarImagePicker` widget for selecting and cropping images.
- Added `FullScreenImageViewer` widget for displaying images in full screen.
- Supports picking images from device gallery or camera.
- Supports cropping images before selecting.
- Provides callbacks to access selected images.
