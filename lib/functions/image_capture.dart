import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';


class ImageCapture {
  File? image;
  final picker = ImagePicker();
  String extractedText = "Waiting for response...";

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      image = File(pickedFile.path);
      sendToN8n(File(pickedFile.path));
    }
  }

  Future<void> sendToN8n(File imageFile) async {
    String url = "http://192.168.0.106:5678/webhook-test/receipt_reader";
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(
      await http.MultipartFile.fromPath(
        'file', // Key name for n8n webhook
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
    try {
      var response = await request.send();
      var responseText = await response.stream.bytesToString();
      extractedText = responseText;
      print("Extracted Text: $extractedText");
      askGroq(responseText);
    } catch (e) {
      print("Request failed: $e");
    }
  }

  Future<void> askGroq(final text) async {
    // String base64Image = await encodeImage(image);
    final url = Uri.parse("https://api.groq.com/openai/v1/chat/completions");
    final apiKey =
        "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"; // Replace with your Groq API Key

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "llama-3.2-90b-vision-preview", // or "mixtral-8x7b"
        "messages": [
          {"role": "system", "content": "You are a helpful AI accountant."},
          {
            "role": "user",
            "content": [
              {
                "type": "text",
                "text": "This is a text extract from the image: " +
                    text +
                    ". Return a json respond with date, total and each item's price."
              },
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Groq Response: ${data['choices'][0]['message']['content']}");
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
    }
  }
}