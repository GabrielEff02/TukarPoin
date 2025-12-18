import 'dart:async';

import '../core/app_export.dart';

class WidgetHelper {
  static Widget cardWidget(String title, String storeName, String subtitle,
      {String description = "", Color? color}) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.all(10.h),
        decoration: BoxDecoration(
          color: color ?? Colors.blue[50],
          borderRadius: BorderRadius.all(Radius.circular(15.adaptSize)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(10.v),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                Text(
                  title,
                  style: title.length < 15
                      ? CustomTextStyle.titleMediumBluegray900
                      : CustomTextStyle.titleSmallBluegray900,
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 5.h,
                ),
                Divider(
                  color: appTheme.blueGray800,
                  thickness: 1.h,
                  height: 1.h,
                  indent: 10.v,
                  endIndent: 10.v,
                ),
              ]),
              SizedBox(height: 15.h),
              Text(
                storeName,
                style: CustomTextStyle.titleSmallBlack900,
              ),
              SizedBox(
                height: 10.h,
              ),
              Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    "$subtitle\n ${description.isNotEmpty ? description : ""}",
                    style: description.isEmpty
                        ? CustomTextStyle.bodyMediumBlueGray600
                        : CustomTextStyle.bodySmallBlueGray600,
                    textAlign: TextAlign.end,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  static PreferredSizeWidget appbarWidget(Function function, Widget title,
      {List<Widget>? actions}) {
    return AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            function();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: appTheme.blueGray800),
        ),
        title: title,
        actions: actions ?? []);
  }

  static Future<void> showVIPModal(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const VIPCongratsModal(),
    );
  }
}

class VIPCongratsModal extends StatefulWidget {
  const VIPCongratsModal({Key? key}) : super(key: key);

  @override
  State<VIPCongratsModal> createState() => _VIPCongratsModalState();
}

class _VIPCongratsModalState extends State<VIPCongratsModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _countdown = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();

    // Start countdown timer
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _closeModal();
      }
    });
  }

  void _closeModal() {
    _timer?.cancel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade900.withOpacity(0.4),
                  Colors.amber.shade800.withOpacity(0.3),
                  Colors.amber.shade900.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Background sparkles
                ...List.generate(4, (index) => _buildSparkle(index)),

                // Main content
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Crown icon with glow
                      _buildCrownIcon(),
                      const SizedBox(height: 24),

                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Color(0xFFFFF9C4),
                            Color(0xFFFFD54F),
                            Color(0xFFFFF9C4),
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'Selamat!',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Subtitle
                      const Text(
                        'Anda Sekarang VIP',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      const Text(
                        'Nikmati akses eksklusif dan berbagai keistimewaan yang telah kami siapkan khusus untuk Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Timer badge
                      _buildTimerBadge(),
                    ],
                  ),
                ),

                // Close button
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: _closeModal,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Bottom decorative line
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.amber.shade400,
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCrownIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(0.4),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        // Icon container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.shade400,
                Colors.amber.shade600,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.shade600.withOpacity(0.5),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.workspace_premium,
            size: 50,
            color: Color(0xFF1a1a2e),
          ),
        ),
        // Sparkle icon
        const Positioned(
          top: 0,
          right: 10,
          child: Icon(
            Icons.auto_awesome,
            color: Colors.amber,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.amber.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Menutup dalam $_countdown detik',
            style: const TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparkle(int index) {
    final positions = [
      const Offset(40, 40),
      const Offset(320, 80),
      const Offset(80, 280),
      const Offset(320, 320),
    ];

    final delays = [0, 300, 700, 1000];

    return Positioned(
      left: positions[index].dx,
      top: positions[index].dy,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 1000 + delays[index]),
        builder: (context, value, child) {
          return Opacity(
            opacity: (value * 2).clamp(0.0, 1.0) * 0.6,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: index % 2 == 0
                    ? Colors.amber.shade300
                    : Colors.amber.shade400,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
