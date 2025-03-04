import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../utils/format_utils.dart';

class MoreTransactionScreen extends StatefulWidget {
  const MoreTransactionScreen({super.key});

  @override
  _MoreTransactionScreenState createState() => _MoreTransactionScreenState();
}

class _MoreTransactionScreenState extends State<MoreTransactionScreen> {
  int currentPage = 1;
  final int itemsPerPage = 10;
  List<DocumentSnapshot> items = [];
  bool isLoading = false;
  DocumentSnapshot? lastDocument;
  bool hasMoreData = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData({bool isNextPage = false}) async {
    if (isLoading || !hasMoreData) return;
    setState(() => isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('transactions')
        .orderBy('date', descending: true)
        .limit(itemsPerPage);

    if (isNextPage && lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    try {
      QuerySnapshot querySnapshot = await query.get();
      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          if (!isNextPage) items.clear();
          items.addAll(querySnapshot.docs);
          lastDocument = querySnapshot.docs.last;
          hasMoreData = querySnapshot.docs.length == itemsPerPage;
        });
      } else {
        setState(() => hasMoreData = false);
      }
    } catch (e) {
      print('Lỗi khi tải dữ liệu: $e');
    }
    setState(() => isLoading = false);
  }

  void nextPage() {
    if (hasMoreData) {
      setState(() => currentPage++);
      fetchData(isNextPage: true);
    }
  }

  void previousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        lastDocument = null;
        items.clear();
      });
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch Sử Giao Dịch',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.teal,
          ),
        ),
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading && items.isEmpty
                ? _buildLoadingIndicator()
                : _buildTransactionList(),
          ),
          _buildPaginationControls(),
        ],
      ),
      backgroundColor: const Color(0xFFeaedf0),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal[800]!),
      ),
    );
  }

  Widget _buildTransactionList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final data = items[index].data() as Map<String, dynamic>;
        final amount = data['amount'] as num;
        final isIncome = amount >= 0;
        final amountColor = isIncome ? Colors.green[800]! : Colors.red[800]!;
        final icon = isIncome
            ? Icons.arrow_circle_up_rounded
            : Icons.arrow_circle_down_rounded;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: amountColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 28,
                  color: amountColor),
            ),
            title: Text(
              data['title'] ?? 'Giao dịch không tên',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                formatDateV2(DateTime.parse(data['date'])),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrencyV2(amount.toString()),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isIncome ? 'Thu nhập' : 'Chi tiêu',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left_rounded,
                size: 32,
                color: currentPage > 1
                    ? Colors.teal[800]
                    : Colors.grey),
            onPressed: currentPage > 1 ? previousPage : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Trang $currentPage',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.teal[800],
                fontSize: 14,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right_rounded,
                size: 32,
                color: hasMoreData
                    ? Colors.teal[800]
                    : Colors.teal),
            onPressed: hasMoreData ? nextPage : null,
          ),
        ],
      ),
    );
  }
}