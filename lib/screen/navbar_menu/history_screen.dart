import 'dart:convert';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  int totalBalance = 0;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  Future<void> fetchTransactions() async {
    try {
      final String username = await LocalData.getData('user');
      final String balance = await LocalData.getData('point');
      final String apiUrl = "${API.BASE_URL}/api/poin/transactions/$username";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          totalBalance = int.parse(balance);
          transactions = data.map((item) {
            return {
              "transaction_id": item["transaction_id"],
              "date": item["date"],
              "total_amount": item["total_amount"] is String
                  ? (double.parse(item["total_amount"])).toInt()
                  : item["total_amount"].toInt(),
              "isNegative": item["is_negative"] == "true",
              "status": item['status'],
              "name": item['name'],
              "is_delivery": item['is_delivery'],
              "keterangan": item['keterangan']
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load transactions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Riwayat Transaksi',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Color(0xFF2E7D32),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: isLoading
          ? _buildLoadingState()
          : transactions.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: fetchTransactions,
                  color: Color(0xFF2E7D32),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildHeader(),
                        _buildTransactionsList(),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data transaksi...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Transaksi Anda akan muncul di sini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet,
              color: Colors.white,
              size: 40,
            ),
            SizedBox(height: 12),
            Text(
              'Total Saldo',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            FutureBuilder(
              future: LocalData.getData('point'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return Text(
                    '0',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }
                return Text(
                  currencyFormatter.format(int.parse(snapshot.data!)),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(index);
      },
    );
  }

  Widget _buildTransactionCard(int index) {
    final transaction = transactions[index];
    bool isNegative = transaction["isNegative"];
    int totalAmount = transaction["total_amount"];
    DateTime date = DateTime.parse(transaction["date"]);
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isNegative) {
              _showTransactionDetails(transaction['transaction_id']);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                _buildTransactionIcon(isNegative, transaction["status"]),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction['keterangan'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      isNegative
                          ? Column(
                              children: [
                                Text(
                                  transaction['name'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  transaction['is_delivery'] == "1"
                                      ? "Pesanan Dikirim"
                                      : "Pesanan Diambil Sendiri",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                SizedBox(height: 4),
                              ],
                            )
                          : Container(),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 8),
                      _buildStatusChip(transaction["status"], isNegative,
                          transaction['is_delivery'].toString()),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${isNegative ? '-' : '+'}${currencyFormatter.format(totalAmount)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isNegative ? Colors.red[600] : Colors.green[600],
                      ),
                    ),
                    if (isNegative)
                      Icon(
                        Icons.chevron_right,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionIcon(bool isNegative, String status) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isNegative ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isNegative ? Icons.shopping_cart : Icons.add_circle,
        color: isNegative ? Colors.red[600] : Colors.green[600],
        size: 24,
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isNegative, String isDelivery) {
    Map<String, dynamic> statusInfo = _getStatusInfo(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: statusInfo['color'].withOpacity(.3),
          width: 1,
        ),
      ),
      child: Text(
        statusInfo['label'],
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: statusInfo['color'],
        ),
      ),
    );
  }

  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case '0':
        return {'label': 'Berhasil', 'color': Colors.green[600]};
      case '1':
        return {'label': 'Ready', 'color': Colors.blue[600]};
      case '2':
        return {'label': 'Pengiriman', 'color': Colors.orange[600]};
      case '3':
        return {'label': 'Selesai', 'color': Colors.purple[600]};
      default:
        return {'label': 'Unknown', 'color': Colors.grey[600]};
    }
  }

  void _showTransactionDetails(int transactionId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailsModal(transactionId),
    );
  }

  Widget _buildTransactionDetailsModal(int transactionId) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt, color: Colors.white, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Detail Transaksi',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchTransactionItems(transactionId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return _buildEmptyTransactionDetails();
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _buildTransactionDetailItem(snapshot.data![index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactionDetails() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'Tidak ada detail item',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailItem(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageView(
                imagePath:
                    "${API.BASE_URL}/images/hadiah_stiker/${item['image_url']}",
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['nama'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Qty: ${item['quantity']}",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "${currencyFormatter.format(double.parse(item['total_price']))}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.red[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchTransactionItems(
      int transactionId) async {
    try {
      final response = await http.get(Uri.parse(
          "${API.BASE_URL}/api/poin/transaction-detail?transaction_id=$transactionId"));

      if (response.statusCode == 200) {
        dynamic jsonResponse = jsonDecode(response.body);
        if (jsonResponse is List) {
          return jsonResponse
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
