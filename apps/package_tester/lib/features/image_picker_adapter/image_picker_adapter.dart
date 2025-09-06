import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker_adapter/image_picker_adapter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Register dependencies for the adapter package
  registerImagePickerAdapterDependencies();

  runApp(const ImagePickerAdapter());
}

class ImagePickerAdapter extends StatelessWidget {
  const ImagePickerAdapter({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExampleApp();
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ImagePickerCubit>(create: (_) => sl<ImagePickerCubit>()),
      ],
      child: MaterialApp(
        title: 'Image Picker Adapter Demo',
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Picker Adapter Demo')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Using AppImagePicker with a custom builder
              AppImagePicker(
                crop: false,
                compress: false,
                imageQuality: 80,
                onChanged: (file) {
                  debugPrint('Picked file path: ${file?.path}');
                },

                builder: (file) {
                  if (file == null) {
                    return const Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.grey,
                    );
                  }
                  return Image.network(
                    // File(file.path),
                    file.path,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                },
              ),

              const SizedBox(height: 30),

              // Using AvatarImagePicker for profile image selection
              AvatarImagePicker(
                radius: 50,
                crop: false,
                compress: false,
                onChanged: (file) {
                  debugPrint('Avatar picked: ${file?.path}');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
