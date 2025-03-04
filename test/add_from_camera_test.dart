// Import the test package and Counter class
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:test/test.dart';
import 'dart:io';
import 'package:expense_personal/view/screens/main/add/add_from_camera.dart';

void main() {
  test('getImageFromCamera should pick an image and update _image', () async {
    final cameraScreen = CameraScreen();

    final state = cameraScreen.createState();

    state.getImageFromCamera();

    expect(state.image, "");
  });

  test('This function should return the content of the image', () async {
    final cameraScreen = CameraScreen();

    final state = cameraScreen.createState();

    state.getImageTotext("");

    expect(state.image, "");
  });
}
