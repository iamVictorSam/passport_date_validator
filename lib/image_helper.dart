import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageHelper {
  ImageHelper({
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<bool> checkPermission() async {
    PermissionStatus status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isRestricted) {
      // Permission is denied or restricted, show a dialog to request permission
      PermissionStatus newStatus = await Permission.camera.request();
      return newStatus.isGranted;
    } else {
      // Permission is permanently denied, show a dialog to open app settings
      bool isOpened = await openAppSettings();
      if (isOpened) {
        // The user opened the app settings, check permission again
        return await checkPermission();
      } else {
        return false;
      }
    }
  }

  pickImage({
    ImageSource source = ImageSource.gallery,
    int imageQuality = 100,
    bool multiple = false,
  }) async {
    bool hasPermission = await checkPermission();
    if (!hasPermission) {
      // Handle the case when permission is not granted
      print('no');
      return [];
    }

    // Permission is granted, proceed with image picking
    if (multiple) {
      return await _imagePicker.pickMultiImage(imageQuality: imageQuality);
    }

    final file = await _imagePicker.pickImage(
      source: source,
      // imageQuality: imageQuality,
    );

    if (file != null) return [file];

    return [];
  }
}
