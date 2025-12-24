import 'dart:convert';

import 'package:e_commerce/constant/dialog_constant.dart';
import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;

class WheelItem {
  final int value;
  double weight;
  String label;
  String color;

  WheelItem(
      {required this.value,
      this.label = '',
      this.weight = 1.0,
      this.color = ''});
}

class WheelFortune extends StatefulWidget {
  const WheelFortune({Key? key}) : super(key: key);

  @override
  State<WheelFortune> createState() => _WheelFortuneState();
}

class _WheelFortuneState extends State<WheelFortune>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool status = false;
  List<WheelItem> items = [];
  int numberOfSections = 10;
  int? result;
  bool isSpinning = false;
  String judul = '';
  String ketentuan = '';
  int chances = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeWheel();
    });
  }

  Future<void> _initializeWheel() async {
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    items.clear();
    await getData();
    await Future.delayed(Duration(milliseconds: 500));

    final loading = await LocalData.getDataBool('isLoading');
    if (mounted && loading) {
      Navigator.of(context).pop();
      LocalData.saveDataBool('isLoading', false);
    }
  }

  Future<void> getData() async {
    final response = await http
        .get(Uri.parse(API.BASE_URL + '/api/poin/get-wheel'))
        .timeout(Duration(seconds: 30));
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      final chance = await LocalData.getData('chance');
      if (mounted) {
        setState(() {
          chances = int.parse(chance);
          judul = data['name'] ?? '';
          ketentuan = data['description'] ?? '';
          for (var item in data['section']) {
            items.add(WheelItem(
                value: (item['value'] is int
                    ? item['value']
                    : int.parse(item['value'])),
                label: (item['label'] is String
                    ? item['label']
                    : item['label'].toString()),
                weight: (item['weight'] is double
                    ? item['weight']
                    : double.parse(item['weight'])),
                color: (item['color'] is String
                    ? item['color']
                    : item['color'].toString())));
            status = true;
          }
        });
      }
    } else {
      setState(() {
        status = false;
      });
    }
  }

  int _getWeightedRandomIndex() {
    double totalWeight = items.fold(0, (sum, item) => sum + item.weight);
    double random = math.Random().nextDouble() * totalWeight;

    double cumulativeWeight = 0;
    for (int i = 0; i < items.length; i++) {
      cumulativeWeight += items[i].weight;
      if (random <= cumulativeWeight) {
        return i;
      }
    }
    return 0;
  }

  void _spin() {
    if (isSpinning) return;

    setState(() {
      isSpinning = true;
      result = null;
    });

    int targetIndex = _getWeightedRandomIndex();
    double sectionAngle = 2 * math.pi / items.length;
    double targetAngle = (targetIndex * sectionAngle) + (sectionAngle / 2);

    double totalRotation = (math.pi * 2 * 5) + (4 * math.pi - targetAngle);

    _animation = Tween<double>(
      begin: 0,
      end: totalRotation,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward(from: 0).then((_) {
      _showWinDialog();
      setState(() {
        result = items[targetIndex].value;
        isSpinning = false;
      });
      _controller.reset();
    });
  }

  void _showWinDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Congratulations!"),
          content: Text("You Won: ${(result)} Point"),
          actions: [
            TextButton(
              onPressed: () async {
                final poin = await LocalData.getData('point');
                final totalPoin = result! + int.parse(poin);
                LocalData.saveData('point', totalPoin.toString());
                LocalData.saveData('max_point', totalPoin.toString());

                Navigator.of(context).pop();
                _updatePointsInDatabase();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updatePointsInDatabase() async {
    try {
      final username = await LocalData.getData('user');
      int points = result!;
      final vip = await LocalData.getData('vip');
      final poin = await LocalData.getData('point');
      if (vip == '0' && int.parse(poin) >= 1500) {
        WidgetHelper.showVIPModal(context, () {
          LocalData.saveData('vip', '1');
        });
      }
      // Send data to the server
      final response = await API.basePost(
          '/api/poin/earn-point',
          {
            'username': username,
            'points': points,
            'deskripsi': 'Anda Mendapatkan $points Point dari Spining Wheel',
            'date': DateTime.now().toString(),
          },
          {'Content-Type': 'application/json'},
          true,
          (result, error) {});
    } catch (e) {
      print('Error updating points: $e');
    }
  }

  Widget _spiningTitle() {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.only(left: 20, top: 50, right: 20),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          border: Border.all(
            color: Colors.yellowAccent,
            width: 2,
          ),
          gradient: const LinearGradient(
            colors: [
              Color.fromARGB(255, 91, 0, 107),
              Color.fromARGB(255, 235, 42, 203),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              judul,
              style: TextStyle(
                fontSize: 19,
                color: Colors.yellowAccent,
              ),
            ),
            _spendingInfoButton(),
          ],
        ),
      ),
    );
  }

  void _showSpendingInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white, // White background
          title: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.yellowAccent, // Blue
                size: 30,
              ),
              const SizedBox(width: 10),
              const Text(
                "Info Kesempatan Undi",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent, // Blue
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 137, 35, 155),
                      Color.fromARGB(255, 235, 42, 203),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      ketentuan,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4CAF50), // Green
                            Color(0xFF66BB6A), // Light Green
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "🎯 Belanja lebih banyak = Lebih banyak kesempatan!",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _spendingInfoButton() {
    return Container(
      child: IconButton(
        onPressed: _showSpendingInfoDialog,
        icon: const Icon(
          Icons.info_outline,
          color: Colors.white,
          size: 24,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: CircleBorder(),
          elevation: 5,
        ),
      ),
    );
  }

  Widget _chanceRemaining() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        "Remaining Chances: $chances",
        style: TextStyle(
          fontSize: 20,
          color: Colors.orangeAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                "https://i.pinimg.com/736x/e7/3a/b8/e73ab8cbf6752d9523558f9c2c63da78.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: status && (mounted)
              ? Column(
                  children: [
                    _spiningTitle(),
                    SizedBox(height: 10),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 38, left: 30, right: 30, bottom: 20),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.5,
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                          fit: BoxFit.contain,
                          image: AssetImage("assets/images/belt.png"),
                        )),
                        child: InkWell(
                          onTap: () {
                            if (!isSpinning && chances > 0) {
                              _spin();
                              isSpinning = true;
                              chances--;
                              LocalData.saveData('chance', chances.toString());
                            } else if (chances == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('No chances left!')),
                              );
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _animation.value,
                                    child: CustomPaint(
                                      size: const Size(300, 300),
                                      painter: WheelPainter(items: items),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    _chanceRemaining(),
                  ],
                )
              : Container(),
        ),
      ),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<WheelItem> items;

  WheelPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final sectionAngle = 2 * math.pi / items.length;

    final paint = Paint()..style = PaintingStyle.fill;

    // Colors for sections

    for (int i = 0; i < items.length; i++) {
      final startAngle = i * sectionAngle - math.pi / 2;
      paint.color = Color(int.parse(items[i].color.replaceFirst('#', '0xff')));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        paint,
      );

      // Draw border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sectionAngle,
        true,
        borderPaint,
      );

      // Draw text
      final textAngle = startAngle + sectionAngle / 2;
      final textRadius = radius * 0.7;
      final textX = center.dx + textRadius * math.cos(textAngle);
      final textY = center.dy + textRadius * math.sin(textAngle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${items[i].value}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 3,
                color: Colors.black45,
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          textX - textPainter.width / 2,
          textY - textPainter.height / 2,
        ),
      );
    }

    // Draw center circle
    paint.color = Colors.white;
    canvas.drawCircle(center, 20, paint);
    paint.color = Colors.grey.shade300;
    canvas.drawCircle(center, 15, paint);
  }

  @override
  bool shouldRepaint(WheelPainter oldDelegate) => true;
}
