import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_personal/widgets/circle_total_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expense_personal/cores/providers/currency_provider.dart';
import '../../../../../cores/utils/format_utils.dart';
import '../../../../../widgets/total_tab.dart';
import '../../../../../widgets/week_calendar_widget.dart';

class TotalSalarysScreen extends StatefulWidget {
  const TotalSalarysScreen({super.key});

  @override
  _TotalSalarysScreenState createState() => _TotalSalarysScreenState();
}

class _TotalSalarysScreenState extends State<TotalSalarysScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _selectedDay;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getIncomesStream() {
    if (_selectedDay == null) return const Stream.empty();

    final startOfDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection('transactions')
        .where('type', isEqualTo: 'income')
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  double _calculateTotal(List<QueryDocumentSnapshot> docs) {
    return docs.fold(0, (sum, doc) => sum + (doc['amount'] as num).toDouble());
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tổng Thu Nhập',
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
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFB0B8BF), width: 1),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
            ),
          ),
        ),
      ),
      body: Consumer<CurrencyProvider>(
        builder: (context, currencyProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 35),
                WeekCalendarWidget(
                  initialDate: DateTime.now(),
                  selectedDay: _selectedDay,
                  onWeekChanged: (newWeek) => setState(() {}),
                  onDaySelected: (date) => setState(() {
                    _selectedDay = DateTime(date.year, date.month, date.day);
                  }),
                ),
                const SizedBox(height: 40),
                StreamBuilder<QuerySnapshot>(
                  stream: _getIncomesStream(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) return Text('Lỗi: ${snapshot.error}');
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    final docs = snapshot.data!.docs;
                    final total = _calculateTotal(docs);
                    final convertedTotal = currencyProvider.convert(total);
                    final formattedTotal = formatCurrency(convertedTotal, currencyProvider.currency);

                    return Column(
                      children: [
                        TotalCircle(total: formattedTotal),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Tổng thu nhập ngày ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF242D35),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        _buildTabSection(docs, currencyProvider),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      backgroundColor: const Color(0xFFeaedf0),
    );
  }

  Widget _buildTabSection(List<QueryDocumentSnapshot> docs, CurrencyProvider currencyProvider) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: TotalTab(
        tabController: _tabController,
        spendsData: _processFirestoreDocs(docs, currencyProvider),
        categoriesData: [],
      ),
    );
  }

  List<Map<String, dynamic>> _processFirestoreDocs(
      List<QueryDocumentSnapshot> docs,
      CurrencyProvider currencyProvider
      ) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final amount = (data['amount'] as num).toDouble();

      return {
        'title': data['title']?.toString() ?? 'Không có tiêu đề',
        'amount': currencyProvider.convert(amount),
        'displayAmount': formatCurrency(
            currencyProvider.convert(amount),
            currencyProvider.currency
        ),
        'category': data['category']?.toString() ?? 'Khác',
        'date': _parseFirestoreDate(data['date'] as String?),
        'createdAt': _parseTimestamp(data['createdAt']),
        'type': data['type'] ?? 'income',
      };
    }).toList();
  }

  DateTime _parseFirestoreDate(String? dateString) {
    if (dateString == null) return DateTime.now();
    try {
      return DateTime.parse(dateString.split('.')[0]);
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    return DateTime.now();
  }
}
