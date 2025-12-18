import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:intl/intl.dart';

class BuktiScreen extends StatefulWidget {
  const BuktiScreen({super.key, required this.header, required this.item});
  final List<Map<String, dynamic>> header;
  final List<Map<String, dynamic>> item;
  @override
  State<BuktiScreen> createState() => _BuktiScreenState();
}

class _BuktiScreenState extends State<BuktiScreen> {
  NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: '',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final headerData = widget.header.first;

    DateTime transactionDate = DateTime.parse(headerData["date"]);
    String formattedTransactionDate =
        DateFormat('HH:mm, dd MMMM yyyy').format(transactionDate);
    String formattedPickupDate = '';
    if (headerData['tgl_ambil'] != null &&
        headerData['tgl_ambil'].toString().isNotEmpty) {
      DateTime pickupDate = DateTime.parse(headerData['tgl_ambil']);
      formattedPickupDate = DateFormat('dd MMMM yyyy').format(pickupDate);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Bukti Pengambilan',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Header Receipt
            _buildReceiptHeader(headerData, formattedTransactionDate),

            SizedBox(height: 30),

            // Divider
            Container(
              width: double.infinity,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(1),
              ),
            ),

            SizedBox(height: 20),

            // Items List
            _buildItemsList(),

            SizedBox(height: 20),

            // Total Section
            _buildTotalSection(headerData),

            SizedBox(height: 30),

            // Footer
            _buildReceiptFooter(formattedPickupDate),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptHeader(
      Map<String, dynamic> headerData, String transactionDate) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF2E7D32).withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo/Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.receipt_long,
              color: Color(0xFF2E7D32),
              size: 30,
            ),
          ),

          SizedBox(height: 16),

          Text(
            'BUKTI PENGAMBILAN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          SizedBox(height: 8),

          Text(
            'Tiara Dewata Group',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 20),

          // Receipt Info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                _buildReceiptInfoRow(
                    'No. Bukti', headerData['no_bukti'] ?? 'N/A'),
                SizedBox(height: 12),
                _buildReceiptInfoRow('Tanggal \nTransaksi', transactionDate),
                SizedBox(height: 12),
                _buildReceiptInfoRow('Cabang', headerData['name'] ?? 'N/A'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detail Item',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 16),
        ...widget.item.map((item) => _buildItemRow(item)).toList(),
      ],
    );
  }

  Widget _buildItemRow(Map<String, dynamic> item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CustomImageView(
              imagePath:
                  "${API.BASE_URL}/images/hadiah_stiker/${item['image_url']}",
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama'] ?? 'Unknown Item',
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
                  "Qty: ${item['quantity'] ?? 0}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "${currencyFormatter.format(item['total_price'] is int ? item['total_price'] : int.parse(item['total_price'].toString()))} Poin",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection(Map<String, dynamic> headerData) {
    int totalAmount = headerData["total_amount"] is String
        ? (double.parse(headerData["total_amount"])).toInt()
        : headerData["total_amount"].toInt();

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Poin',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                "${currencyFormatter.format(totalAmount)} Poin",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildReceiptFooter(formattedPickupDate) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.verified,
                color: Color(0xFF2E7D32),
                size: 40,
              ),
              SizedBox(height: 8),
              Text(
                'Terima kasih telah menggunakan layanan kami',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4),
              Text(
                'Simpan bukti ini sebagai tanda terima',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Dicetak pada: $formattedPickupDate',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
