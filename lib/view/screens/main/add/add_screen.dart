import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:provider/provider.dart';
import '../../../../cores/utils/format_utils.dart';
import '../../../../cores/utils/getUserId.dart';
import '../../../../cores/providers/currency_provider.dart';

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

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  String? userId = getCurrentUserId();

  Future<void> _loadTransactions() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('transactions')
          .where('userId', isEqualTo: userId)
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
            'amount': data['amount'] ?? 0,
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
    final currencyProvider = Provider.of<CurrencyProvider>(context);

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
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : Expanded(
                    child: AnimatedOpacity(
                      opacity: isLoading ? 0 : 1,
                      duration: const Duration(seconds: 1),
                      child: ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          final amount = transaction['amount'] as num;
                          final convertedAmount = transaction['type'] == 'income'
                              ? amount.toDouble()
                              : -amount.toDouble();
                          final formattedAmount = formatCurrency(
                              currencyProvider.convert(convertedAmount.abs()),
                              currencyProvider.currency
                          );
                          final displayAmount = '${transaction['type'] == 'income' ? '+' : '-'}$formattedAmount';

                          return Dismissible(
                            key: Key(transaction['id'] ?? index.toString()),
                            direction: DismissDirection.horizontal,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (direction) async {
                              try {
                                final docId = transactions[index]['id'];

                                if (docId != null) {
                                  await _firestore
                                      .collection('transactions')
                                      .doc(docId)
                                      .delete();
                                  print("Giao dịch đã bị xoá khỏi Firestore: $docId");
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                formatDateV2(
                                    DateTime.parse(transaction['date'])),
                              ),
                              trailing: Text(
                                displayAmount,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: transaction['type'] == 'income'
                                      ? Colors.teal
                                      : Colors.red,
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
        dashPattern: const [6, 6],
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