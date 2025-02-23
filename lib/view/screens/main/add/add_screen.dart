import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';



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

  Future<void> sendDataToN8N(Map<String, dynamic> data) async {
    final url = Uri.parse("http://localhost:5678/webhook-test/af76d4e3-4705-4985-a850-e7065ac9d6df");

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

  File _image= File("");
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

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        // sendDataToN8N({"image": _image});
        sendImageToHuggingFace(_image);
      }
    });
  }


  Future<void> sendImageToHuggingFace(File _image) async {
    String apiUrl = "https://api-inference.huggingface.co/models/Salesforce/blip-image-captioning-base";
    String token = "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";  // Replace with your API key

    // Pick an image from gallery
    XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return; // User canceled

    File imageFile = File(pickedFile.path);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    Map<String, dynamic> requestBody = {
      "inputs": [
        {"image": base64Image, "text": "Can you read the receipt image and tell me how much i spent?"}
      ]
    };

    var response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print("Caption: ${jsonResponse[0]["generated_text"]}");
    } else {
      print("Error: ${response.body}");
    }
  }

  Future<void> askOllama(File _image) async {
    final url = Uri.parse("http://localhost:11434/api/generate");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "model": "llama3.2-vision:11b",  // Use "llama3", "gemma", etc.
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
  Future<void> askOpenAI(File _image) async {
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");
    final apiKey = "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"; // Replace with your OpenAI API Key

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",  // or "gpt-3.5-turbo"
        "messages": [
          {"role": "system", "content": "You are a helpful AI."},
          {"role": "user", "content": "Greet me!"}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("OpenAI Response: ${data['choices'][0]['message']['content']}");
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
    }
  }
  Future<void> askGroq(File _image) async {
    String base64Image = await encodeImage(_image);
    final url = Uri.parse("https://api.groq.com/openai/v1/chat/completions");
    final apiKey = "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"; // Replace with your Groq API Key

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "llama-3.2-90b-vision-preview",  // or "mixtral-8x7b"
        "messages": [
          {"role": "system", "content": "You are a helpful AI accountant."},
          {"role": "user", "content": [
            {"type": "text", "text": "Can you read the image and tell me how much i spent?"},
            {"type": "image_url", "image_url": "data:image/png;base64,$base64Image"}
          ]}
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

  final List<Map<String, dynamic>> transactions = [
    {
      'icon': Icons.shopping_cart,
      'title': 'Mua sắm',
      'amount': '-500.000đ',
      'date': 'Hôm nay',
      'color': Color(0xFFEBEEF0),
    },
    {
      'icon': Icons.restaurant,
      'title': 'Ăn uống',
      'amount': '-200.000đ',
      'date': 'Hôm qua',
      'color': Color(0xFFEBEEF0),
    },
    {
      'icon': Icons.attach_money,
      'title': 'Lương',
      'amount': '+10.000.000đ',
      'date': '2 ngày trước',
      'color': Color(0xFFEBEEF0),
    },
  ];

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
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: GestureDetector(
            onTap: () => context.pop('/home'),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Color(0xFFB0B8BF), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: 18
              ),
            ),
          ),
        ),
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
                  onTap: () => context.go('/addExpense'),
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
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: transaction['color'],
                            child: Icon(
                              transaction['icon'],
                              color: Colors.black,
                            ),
                          ),
                          title: Text(transaction['title']),
                          subtitle: Text(transaction['date']),
                          trailing: Text(
                            transaction['amount'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: transaction['amount'].startsWith('-')
                                  ? Colors.black
                                  : Colors.black,
                            ),
                          ),
                        );
                      },
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
            getImageFromCamera();
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
    required VoidCallback onTap, // Thêm callback để xử lý sự kiện nhấn
  }) {
    return SizedBox(
      width: 130,
      height: 100,
      child: InkWell(
        onTap: onTap, // Gọi hàm `onTap` khi nhấn
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
