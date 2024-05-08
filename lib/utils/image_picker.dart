import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageVideoPicker {
  /// Retrieves an image either from the gallery or camera based on the user's choice.
  ///
  /// This method asynchronously picks an image using the `ImagePicker` package.
  /// The source of the image is determined by the [fromGallery] parameter.
  /// If [fromGallery] is true, the image is picked from the gallery, otherwise from the camera.
  /// The image quality is set to 40 to reduce the file size and memory usage.
  ///
  /// [context] is used to display a `SnackBar` in case of an error during the image picking process.
  ///
  /// Returns a [File] object of the picked image. If an error occurs or the operation is cancelled,
  /// it returns null.
  ///
  /// Parameters:
  ///   - [fromGallery]: A boolean value determining the source of the image.
  ///   - [context]: The BuildContext used for showing the SnackBar in case of an error.
  ///
  /// Throws:
  ///   - This method does not explicitly throw any errors but catches and handles them in snackbar.
  static Future<File?> getImage(bool fromGallery, BuildContext context) async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        source: fromGallery == true ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 40,
      );
      return File(pickedImage!.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Something went wrong during getting image ${e.toString()}"),
        ),
      );
    }
  }

  static Future<File?> getVideo(bool fromGallery, BuildContext context) async {
    try {
      final pickedVideo = await ImagePicker().pickVideo(
        source: fromGallery == true ? ImageSource.gallery : ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );

      return File(pickedVideo!.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Something went wrong during getting video ${e.toString()}"),
        ),
      );
    }
  }
}
