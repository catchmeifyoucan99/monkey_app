import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  File? _image;
  File get image => _image!;
  final picker = ImagePicker();

  Future getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    // await copyTessData();
    // await checkTessDataFiles();
    // await loadTessConfig();
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        // _extractText(pickedFile.path);
        // sendDataToN8N({"image": _image});
        // sendImageToHuggingFace(_image);
        // getImageTotext(_image?.path);
        // sendToOllama(_image);
        sendToN8n(File(pickedFile.path));
      }
    });
  }

  Future<void> sendToN8n(File imageFile) async {
    String url = "http://192.168.0.106:5678/webhook-test/receipt_reader"; // Update with your webhook URL

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

      print("Extracted Text: $_extractedText");

      // if (response.statusCode == 200) {
      //   // Convert response to string
      //   var responseBody = await response.stream.bytesToString();
      //   var jsonResponse = jsonDecode(responseBody);
      //
      //   // Extract data
      //   String extractedText = jsonResponse["text"];
      //
      //   // Display in UI
      //   setState(() {
      //     _extractedText = extractedText;
      //   });
      //
      //   print("Extracted Text: $_extractedText");
      // } else {
      //   print("Error: ${response.statusCode}");
      // }
    } catch (e) {
      print("Request failed: $e");
    }
  }

  String _extractedText = "Waiting for response...";

  Future getImageTotext(final imagePath) async {
    final textRecognizer = TextRecognizer();
    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(InputImage.fromFilePath(imagePath));
      String text = formatTextWithSorting(recognizedText);
      print("Text: $text");
      askGroq(text);
    } finally {
      textRecognizer.close();
    }
  }

  String formatTextWithSorting(RecognizedText recognizedText) {
    List<TextLine> allLines = [];

    for (TextBlock block in recognizedText.blocks) {
      allLines.addAll(block.lines);
    }

    // Sort lines first by Y position, then by X position
    allLines.sort((a, b) {
      int dy = a.boundingBox.top.compareTo(b.boundingBox.top);
      return (dy != 0) ? dy : a.boundingBox.left.compareTo(b.boundingBox.left);
    });

    return allLines.map((line) => line.text).join("\n");
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
                    ". Tell me how much I spent in VND currency."
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

  // @override
  // void initState() {
  //   super.initState();
  //   initCamera();
  // }

  Future<void> sendToOllama(image) async {
    if (image == null) {
      print("image is null");
      return;
    };

    // Compress image (optional, to reduce size)
    List<int> imageBytes = await image!.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // Ollama API URL (adjust if using a remote server)
    String url = 'http://127.0.0.1:11434/api/generate';

    // Request body
    Map<String, dynamic> body = {
      "model": "llava:7b", // Use an image-capable model like `llava`
      "prompt": "Describe this image",
      "images": [base64Image]
    };

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("Ollama Response: ${jsonResponse['response']}");
      } else {
        print("ERROR: ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }


  // Future<void> initCamera() async {
  //   _cameras = await availableCameras();
  //   if (_cameras!.isNotEmpty) {
  //     _cameraController =
  //         CameraController(_cameras![0], ResolutionPreset.medium);
  //     await _cameraController!.initialize();
  //     setState(() {});
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   _cameraController?.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chụp Hình")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Expanded(
            //   child: _cameraController != null &&
            //           _cameraController!.value.isInitialized
            //       ? CameraPreview(_cameraController!)
            //       : Center(child: CircularProgressIndicator()),
            // ),
            ElevatedButton(
              onPressed: getImageFromCamera,
              child: Text("Chụp Hình"),
            ),
            SizedBox(height: 10),
            // if (_image != null) ...[
            //   SizedBox(height: 10),
            //   Text("Ảnh đã chụp:"),
            //   Image.file(File(_image!.path), height: 200),
            // ],
            _image != null ?
            Image.file(_image!, height: 200) :
            Text('No image selected'),
            SizedBox(height: 10),
            Text(_extractedText, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
