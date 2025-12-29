import 'dart:convert';
import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:e_commerce/screen/navbar_menu/bukti_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> currentPeriodTransactions = [];
  List<Map<String, dynamic>> previousPeriodTransactions = [];
  bool isLoading = true;
  int totalBalance = 0;
  int totalBalancePrev = 0;
  late TabController _tabController;
  Map<String, dynamic> periodeNow = {};
  Map<String, dynamic> periodePrevious = {};

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      periodeNow = jsonDecode(await LocalData.getData('current_period'));
      if (await LocalData.containsKey('previous_period')) {
        periodePrevious =
            jsonDecode(await LocalData.getData('previous_period'));
      }
      _tabController = TabController(
          length: periodePrevious.isNotEmpty ? 2 : 1, vsync: this);

      final String apiUrl = "${API.BASE_URL}/api/poin/transactions/$username";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        // Dapatkan tanggal saat ini
        DateTime startOfCurrentMonth =
            DateTime.parse(periodeNow['tanggal_mulai_pengumpulan']);
        DateTime endOfCurrentMonth =
            DateTime.parse(periodeNow['tanggal_akhir_pengumpulan']);

        List<Map<String, dynamic>> current = [];
        List<Map<String, dynamic>> previous = [];

        for (var item in data) {
          Map<String, dynamic> transaction = {
            "transaction_id": item["transaction_id"],
            "date": item["date"],
            "total_amount": item["total_amount"] is String
                ? (double.parse(item["total_amount"])).toInt()
                : item["total_amount"].toInt(),
            "isNegative": item["is_negative"] == "true",
            "status": item['status'],
            "name": item['name'],
            "is_delivery": item['is_delivery'],
            "no_bukti": item['no_bukti'],
            "waktu_ambil": item['waktu_ambil'],
            "sudah_ambil": item['sudah_ambil'],
            "tgl_ambil": item['tgl_ambil'],
            "keterangan": item['keterangan']
          };

          DateTime transactionDate = DateTime.parse(item["date"]);

          // Pisahkan berdasarkan periode
          if (transactionDate.isAfter(startOfCurrentMonth) &&
              transactionDate.isBefore(endOfCurrentMonth)) {
            current.add(transaction);
          } else {
            previous.add(transaction);
          }
        }

        setState(() {
          totalBalance = int.parse(balance);
          currentPeriodTransactions = current;
          previousPeriodTransactions = previous;
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
    return isLoading
        ? _buildLoadingState()
        : Scaffold(
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
              backgroundColor: Color(0xFFF0830F),
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.white),
              centerTitle: true,
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: [
                  Tab(text: 'Periode Saat Ini'),
                  if (periodePrevious.isNotEmpty)
                    Tab(text: 'Periode Sebelumnya'),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionTab(currentPeriodTransactions),
                if (periodePrevious.isNotEmpty)
                  _buildTransactionTab(previousPeriodTransactions, now: false),
              ],
            ),
          );
  }

  Widget _buildTransactionTab(List<Map<String, dynamic>> transactions,
      {bool now = true}) {
    if (transactions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: fetchTransactions,
      color: Color(0xFF2E7D32),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(now),
            _buildTransactionsList(transactions),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF0830F)),
            ),
          ],
        ),
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

  Widget _buildHeader(bool now) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9A3412), // orange gelap
            Color(0xFFF97316), // orange terang
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF9A3412).withOpacity(0.3),
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
              future: LocalData.getData(now ? 'point' : 'prev_point'),
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

  Widget _buildTransactionsList(List<Map<String, dynamic>> transactions) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        return _buildTransactionCard(transactions[index]);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    bool isNegative = transaction["isNegative"];
    int totalAmount = transaction["total_amount"];
    DateTime date = DateTime.parse(transaction["date"]);
    String formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(date);
    String formattedWaktuAmbil = '';
    if (isNegative) {
      DateTime waktuAmbil = DateTime.parse(transaction["waktu_ambil"].trim());
      formattedWaktuAmbil = DateFormat('dd MMM yyyy').format(waktuAmbil);
    }

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
              _showTransactionDetails(
                  transaction['no_bukti'],
                  transaction['transaction_id'],
                  transaction['name'],
                  transaction['sudah_ambil'] == 1 ? true : false,
                  transaction['status']);
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
                      if (isNegative) ...[
                        Text(
                          transaction['name'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 4)
                      ],
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      SizedBox(height: 4),
                      if (isNegative) ...[
                        Text(
                          'Tanggal Pengambilan: $formattedWaktuAmbil',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatusChip(transaction["status"], isNegative,
                                transaction['is_delivery'].toString()),
                            SizedBox(width: 8),
                            _buildPickupStatusChip(transaction["sudah_ambil"])
                          ],
                        )
                      ],
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

  Widget _buildPickupStatusChip(int sudahAmbil) {
    bool isPickedUp = sudahAmbil == 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPickedUp
            ? Colors.green[600]!.withOpacity(0.1)
            : Colors.orange[600]!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPickedUp
              ? Colors.green[600]!.withOpacity(0.3)
              : Colors.orange[600]!.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        isPickedUp ? 'Sudah Diambil' : 'Belum Diambil',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: isPickedUp ? Colors.green[600] : Colors.orange[600],
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
        return {'label': 'Berhasil', 'color': Colors.blue[600]};
      case '1':
        return {'label': 'Ready', 'color': Colors.blue[600]};
      case '2':
        return {'label': 'Pengiriman', 'color': Colors.orange[600]};
      case '3':
        return {'label': 'Selesai', 'color': Colors.green[600]};
      default:
        return {'label': 'Unknown', 'color': Colors.grey[600]};
    }
  }

  void _showTransactionDetails(String? noBukti, int transactionId,
      String cabang, bool sudahAmbil, String status) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildTransactionDetailsModal(
          noBukti, transactionId, cabang, sudahAmbil, status),
    );
  }

  Widget _buildTransactionDetailsModal(String? noBukti, int transactionId,
      String cabang, bool sudahAmbil, String status) {
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
                    noBukti ?? 'Detail Transaksi',
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

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return _buildTransactionDetailItem(
                              snapshot.data![index]);
                        },
                      ),
                    ),
                    if (!sudahAmbil && status == '3')
                      _buildPickupButton(transactionId, noBukti, cabang),
                    if (sudahAmbil && status == '3')
                      _buildReceiptButton(transactionId, noBukti, cabang),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupButton(int transactionId, String? noBukti, String cabang) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              "Ambil Pesanan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _showPasswordDialog(transactionId, noBukti, cabang);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptButton(
      int transactionId, String? noBukti, String cabang) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF2E7D32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: Icon(
              Icons.receipt_long,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              "Lihat Bukti Pengambilan",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: () {
              _showReceipt(transactionId, noBukti, cabang);
            },
          ),
        ),
      ),
    );
  }

  void _showReceipt(int transactionId, String? noBukti, String cabang) async {
    try {
      DialogConstant.loading(context, 'Loading...');
      List<Map<String, dynamic>> items =
          await _fetchTransactionItems(transactionId);

      Map<String, dynamic>? headerData;
      // Cari di kedua list transaksi
      for (var transaction in [
        ...currentPeriodTransactions,
        ...previousPeriodTransactions
      ]) {
        if (transaction['transaction_id'] == transactionId) {
          headerData = transaction;
          break;
        }
      }

      if (headerData != null && items.isNotEmpty) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuktiScreen(
              header: [headerData!],
              item: items,
            ),
          ),
        );
      } else {
        DialogConstant.alertError('Error', 'Tidak dapat memuat data bukti');
      }
    } catch (e) {
      DialogConstant.alertError('Error', 'Terjadi kesalahan saat memuat bukti');
    }
  }

  void _showPasswordDialog(int transactionId, String? noBukti, String cabang) {
    final TextEditingController passwordController = TextEditingController();
    bool isPasswordVisible = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 16,
              backgroundColor: Colors.white,
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2E7D32).withOpacity(0.05),
                        Colors.white,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF2E7D32),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2E7D32).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Konfirmasi Pengambilan",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Konfirmasi pengambilan pesanan dilakukan pada saat berada di $cabang:",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "No. Bukti: ${noBukti ?? 'N/A'}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      TextFormField(
                        controller: passwordController,
                        obscureText: !isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: "Password",
                          hintText: "Masukkan password Anda",
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: Color(0xFF2E7D32),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                isPasswordVisible = !isPasswordVisible;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Color(0xFF2E7D32), width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.grey[400]!,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: Text(
                                'Batal',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF2E7D32),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14),
                                elevation: 2,
                              ),
                              child: Text(
                                'Konfirmasi',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: () {
                                if (passwordController.text.isEmpty) {
                                  DialogConstant.alert(
                                      "Password tidak boleh kosong");
                                  return;
                                }
                                Navigator.of(context).pop();
                                _processPickup(transactionId,
                                    passwordController.text, noBukti);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _processPickup(
      int transactionId, String password, String? noBukti) async {
    DialogConstant.loading(context, "Memproses pengambilan...");
    final username = await LocalData.getData('user');

    API.basePost(
        '/api/poin/confirm-pickup',
        {
          'noBukti': noBukti,
          'password': password,
          'username': username,
          'tgl_ambil': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        },
        {'Content-Type': 'application/json'},
        true, (result, error) {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      if (error != null) {
        print(error);
        DialogConstant.alertError('Gagal', error['message']);
        return;
      }
      if (result != null && result['error'] == true) {
        print(error);

        DialogConstant.alertError('Gagal', result['message']);
        return;
      } else {
        DialogConstant.showSuccessAlert(
            title: "Berhasil",
            message:
                "Pengambilan pesanan dengan No. Bukti: ${noBukti ?? 'N/A'} berhasil dikonfirmasi.",
            onComplete: () => fetchTransactions());
      }
    });
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
              "${currencyFormatter.format(item['total_price'] is int ? item['total_price'] : int.parse(item['total_price']))}",
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
