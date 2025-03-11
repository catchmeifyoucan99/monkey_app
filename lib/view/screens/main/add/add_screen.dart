import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
// import 'package:ocr_scan_text/ocr_scan_text.dart';
// import 'package:ocr_scan_text_example/scan_all_module.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import '../../../../utils/format_utils.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  Future<String> encodeImage(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  List<Map<String, dynamic>> transactions = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = true;

  Future<void> sendDataToN8N(Map<String, dynamic> data) async {
    final url = Uri.parse(
        "http://localhost:5678/webhook-test/af76d4e3-4705-4985-a850-e7065ac9d6df");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        print("Data sent successfully: ${response.body}");
      } else {
        print("Error: ${response.statusCode}, ${response.body}");
      }
    } catch (e) {
      print("Exception: $e");
    }
  }

  File _image = File("");
  final picker = ImagePicker();
  Future getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

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
        getImageTotext(_image.path);
      }
    });
  }

  Future<void> copyTessData() async {
    final directory = await getApplicationDocumentsDirectory();
    final tessdataPath = '${directory.path}/tessdata';
    final tessdataDir = Directory(tessdataPath);

    if (!await tessdataDir.exists()) {
      await tessdataDir.create(recursive: true);
    }

    final trainedDataFiles = ['eng.traineddata', 'tha.traineddata'];

    for (final fileName in trainedDataFiles) {
      final assetPath = 'assets/tessdata/$fileName';
      final filePath = '$tessdataPath/$fileName';

      final file = File(filePath);
      if (!(await file.exists())) {
        final ByteData data = await rootBundle.load(assetPath);
        final List<int> bytes = data.buffer.asUint8List();
        await file.writeAsBytes(bytes);
        print("✅ Copied $fileName to $tessdataPath");
      } else {
        print("⚠️ $fileName already exists in $tessdataPath");
      }
    }
  }

  Future<Map<String, dynamic>> loadTessConfig() async {
    try {
      String configString =
          await rootBundle.loadString('assets/tessdata_config.json');
      final Map<String, dynamic> config = json.decode(configString);
      print("Tesseract Config Loaded: $config");
          return config;
    } catch (e) {
      print("Error loading tessdata_config.json: $e");
      return {};
    }
  }

  Future<void> checkTessDataFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final tessdataPath = '${directory.path}/tessdata';

    final engFile = File('$tessdataPath/eng.traineddata');
    final thaFile = File('$tessdataPath/tha.traineddata');

    print("Checking tessdata files...");

    if (await engFile.exists()) {
      print("✅ eng.traineddata exists at $tessdataPath");
    } else {
      print("❌ eng.traineddata is MISSING! Copy it manually.");
    }

    if (await thaFile.exists()) {
      print("✅ tha.traineddata exists at $tessdataPath");
    } else {
      print("❌ tha.traineddata is MISSING! Copy it manually.");
    }
  }

  Future<void> _extractText(String imagePath) async {
    if (imagePath.isEmpty) {
      print("Error: Image path is empty!");
      return;
    }
    final directory = await getApplicationDocumentsDirectory();
    final tessdataParent = directory.path;
    String text = await FlutterTesseractOcr.extractText(
      imagePath,
      language: 'eng',
      args: {
        "tessdata": tessdataParent,
      },
    );
    print("Text: $text");

    // setState(() {
    //   _ocrText = text;
    // });
  }

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

  String formatTextWithLineBreaks(RecognizedText recognizedText) {
    List<String> formattedLines = [];

    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        formattedLines.add(line.text);
      }
      formattedLines.add(""); // Add a blank line to separate blocks
    }

    return formattedLines.join("\n");
  }

  Future<void> askOllama(File image) async {
    final url = Uri.parse("http://localhost:11434/api/generate");
    List<int> imageBytes = await image.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "model": "llama3.2-vision:11b",
        "prompt": "Can you read the image and tell me how much i spent?"
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("Ollama Response: ${data['response']}");
    } else {
      print("Error: ${response.statusCode}");
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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .orderBy('date', descending: true)
          .limit(7)
          .get();

      print('Dữ liệu từ Firestore: ${snapshot.docs.length} giao dịch');
      for (var doc in snapshot.docs) {
        print(doc.data());
      }

      setState(() {
        transactions = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'title': data['title'] ?? "Không có tiêu đề",
            'amount': data['amount'] >= 0
                ? '+${data['amount']}đ'
                : '${data['amount']}đ',
            'date': data['date'] ?? "Không có ngày",
            'type': data['type'] ?? "Không rõ loại",
            'category': data['category'] ?? "Không có danh mục",
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tải dữ liệu từ Firestore: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Thêm Giao Dịch',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 35),
            child: Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildDottedButton(),
                _buildTransactionButton(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Thêm Thu Nhập',
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: Colors.grey,
                  onTap: () => context.push('/addSalary'),
                ),
                _buildTransactionButton(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Thêm Chi Tiêu',
                  backgroundColor: Colors.teal,
                  textColor: Colors.white,
                  borderColor: Colors.teal,
                  onTap: () => context.push('/addExpense'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(top: 15),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 19),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Các mục nhập mới nhất",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_horiz),
                          onPressed: () {
                            context.push('/moreTransactions');
                          },
                        ),
                      ],
                    ),
                  ),
                  isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : Expanded(
                          child: AnimatedOpacity(
                            opacity: isLoading ? 0 : 1,
                            duration: Duration(seconds: 1),
                            child: ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];
                                return Dismissible(
                                  key: Key(transaction['title']),
                                  direction: DismissDirection.horizontal,
                                  background: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerLeft,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child:
                                        Icon(Icons.delete, color: Colors.white),
                                  ),
                                  secondaryBackground: Container(
                                    color: Colors.red,
                                    alignment: Alignment.centerRight,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child:
                                        Icon(Icons.delete, color: Colors.white),
                                  ),
                                  onDismissed: (direction) async {
                                    try {
                                      final docId = transactions[index]['id'];

                                      if (docId != null) {
                                        await _firestore
                                            .collection('transactions')
                                            .doc(docId)
                                            .delete();
                                        print(
                                            "Giao dịch đã bị xoá khỏi Firestore: $docId");
                                      }

                                      setState(() {
                                        transactions.removeAt(index);
                                      });
                                    } catch (e) {
                                      print("Lỗi khi xoá giao dịch: $e");
                                    }
                                  },
                                  child: ListTile(
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: transaction['type'] == 'income'
                                            ? Colors.teal.withOpacity(0.2)
                                            : Colors.teal.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(9),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          transaction['type'] == 'income'
                                              ? Icons.attach_money
                                              : Icons.shopping_cart,
                                          color: transaction['type'] == 'income'
                                              ? Colors.teal
                                              : Colors.teal,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      transaction['title'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      formatDateV2(
                                          DateTime.parse(transaction['date'])),
                                    ),
                                    trailing: Text(
                                      formatCurrencyV2(transaction['amount']),
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: transaction['type'] == 'income'
                                            ? Colors.black
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFeaedf0),
    );
  }

  Widget _buildDottedButton() {
    return SizedBox(
      width: 70,
      height: 100,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        dashPattern: [6, 6],
        color: Colors.grey,
        strokeWidth: 1.5,
        child: InkWell(
          onTap: () {
            print('Thêm mới giao dịch');
            context.push('/addCamera');
          },
          child: Container(
            height: 100,
            width: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.add, size: 32, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 130,
      height: 100,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 32, color: textColor),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
