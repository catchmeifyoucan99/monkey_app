import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

class CameraScreen extends StatefulWidget {
  final ImagePicker? imagePicker;
  const CameraScreen({super.key, this.imagePicker});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  File? _image;
  File get image => _image!;
  String _extractedText = "Waiting for response...";
  String get extractedText => _extractedText;
  ImagePicker get picker => widget.imagePicker ?? ImagePicker();

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _extractedText = "Waiting for response...";
        _image = File(pickedFile.path);
        sendToN8n(File(pickedFile.path));
      }
    });
  }

  Future<void> sendToN8n(File imageFile) async {
    String url =
        "https://9749-14-161-49-158.ngrok-free.app/webhook/receipt_reader";
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
      setState(() {
        _extractedText = responseText;
      });
      // print("Extracted Text: $_extractedText");
      askGroq(responseText);
    } catch (e) {
      print("Request failed: $e");
      _extractedText = "Request failed!";
    }
  }

  Future<void> askGroq(final text) async {
    // String base64Image = await encodeImage(image);
    final url = Uri.parse("https://api.groq.com/openai/v1/chat/completions");
    final apiKey = "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";
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
                    ". Return a json respond with date, total amount spent in VND."
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chụp Hình")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: getImageFromCamera,
              child: Text("Chụp Hình"),
            ),
            SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 200)
                : Text('No image selected'),
            SizedBox(height: 10),
            Text(_extractedText, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
