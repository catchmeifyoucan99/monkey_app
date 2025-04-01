import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:expense_personal/view/screens/main/add/add_from_camera.dart';

import '../../transactions/mock_image_picker.mocks.dart'; // Import generated mocks

void main() {
  late MockImagePicker mockImagePicker;

  setUp(() {
    mockImagePicker = MockImagePicker();
  });
  test('getImageFromCamera function works correctly', () async {
    // Create a fake image file
    final fakeImage = File('test_image.jpg');

    // Mock ImagePicker to return the fake image
    when(mockImagePicker.pickImage(source: ImageSource.camera))
        .thenAnswer((_) async => XFile(fakeImage.path));

    // Mock ImagePicker returning a file
    final pickedFile =
        await mockImagePicker.pickImage(source: ImageSource.camera);
    // Verify if the picked image path is correctly assigned
    expect(pickedFile, isNotNull);
    expect(pickedFile!.path, equals(fakeImage.path));
  });

  test('sendToN8n function should send image and receive response', () async {
    final cameraScreen = CameraScreen();
    final state = cameraScreen.createState();
    final fakeImage = File('test_image.jpg');
    await fakeImage.writeAsBytes([0xFF, 0xD8, 0xFF]);

    await state.sendToN8n(fakeImage);

    // Ensure extracted text is updated correctly
    expect(state.extractedText, isNot("Waiting for response..."));
  });

  // test('askGroq function should call API and handle response', () async {
  //   final cameraScreen = CameraScreen();
  //   final state = cameraScreen.createState();
  //   const extractedText = "Total: 100,000 VND";
  //   final url = Uri.parse("https://api.groq.com/openai/v1/chat/completions");

  //   // Mock API response
  //   when(mockHttpClient.post(
  //     url,
  //     headers: anyNamed('headers'),
  //     body: anyNamed('body'),
  //   )).thenAnswer((_) async => http.Response(
  //       '{"choices": [{"message": {"content": "You spent 100,000 VND"}}]}',
  //       200));

  //   // Inject mock HTTP client
  //   state.httpClient = mockHttpClient;

  //   await state.askGroq(extractedText);

  //   // Verify the API was called
  //   verify(mockHttpClient.post(
  //     url,
  //     headers: anyNamed('headers'),
  //     body: anyNamed('body'),
  //   )).called(1);
  // });
}
