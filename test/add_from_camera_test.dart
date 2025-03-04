// Import the test package and Counter class
// import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:expense_personal/view/screens/main/add/add_from_camera.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockTextRecognizer extends Mock implements TextRecognizer {}

class MockHttpClient extends Mock implements http.Client {}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // late MockImagePicker mockImagePicker;
  // late MockTextRecognizer mockTextRecognizer;
  // late MockHttpClient mockHttpClient;

  final mockImagePicker = MockImagePicker();
  final mockTextRecognizer = MockTextRecognizer();
  final mockHttpClient = MockHttpClient();
  test('getImageFromCamera should pick an image and update _image', () async {
    final cameraScreen = CameraScreen();
    final fakeImage = XFile('test_image.jpg');

    final state = cameraScreen.createState();

    final result = await state.getImageFromCamera();

    when(mockImagePicker.pickImage(source: ImageSource.camera))
        .thenAnswer((_) async => fakeImage);

    expect(result, isNotNull);
    expect(result?.path, equals('test_image.jpg'));
  });

  test('This function should return the content of the image', () async {
    final cameraScreen = CameraScreen();
    const imagePath = 'test_image.jpg';
    final recognizedText = RecognizedText(
      text: "Total: 100,000 VND",
      blocks: [],
    );
    final inputImage = InputImage.fromFilePath(imagePath);

    final state = cameraScreen.createState();

    when(mockTextRecognizer.processImage(inputImage))
        .thenAnswer((_) async => recognizedText);

    await state.getImageTotext(imagePath);

    verify(mockTextRecognizer.processImage(inputImage)).called(1);
  });

  test('askGroq should send API request and handle response', () async {
    final cameraScreen = CameraScreen();
    final state = cameraScreen.createState();
    const text = "Total: 100,000 VND";
    final url = Uri.parse("https://api.groq.com/openai/v1/chat/completions");

    when(mockHttpClient.post(
      url,
      headers: anyNamed('headers'),
      body: anyNamed('body'),
    )).thenAnswer((_) async => http.Response(
        '{"choices": [{"message": {"content": "You spent 100,000 VND"}}]}',
        200));

    await state.askGroq(text);

    verify(mockHttpClient.post(url,
            headers: anyNamed('headers'), body: anyNamed('body')))
        .called(1);
  });
}
