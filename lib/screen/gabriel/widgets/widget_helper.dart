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

  static PreferredSizeWidget appbarWidget(Widget title,
      {Function? function,
      List<Widget>? actions,
      PreferredSizeWidget? bottom}) {
    final double height = 80.v + (bottom != null ? 100.v : 0);

    return PreferredSize(
      preferredSize: Size.fromHeight(height),
      child: Container(
        margin: EdgeInsets.only(top: 20.h),
        transform: Matrix4.translationValues(0.0, -25.h, 0),
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg_appbar.png'),
            fit: BoxFit.none,
          ),
        ),
        child: SafeArea(
          child: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: (function != null)
                ? IconButton(
                    onPressed: () {
                      function();
                    },
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: appTheme.whiteA700),
                  )
                : null,
            title: title,
            actions: actions ?? [],
            bottom: bottom,
          ),
        ),
      ),
    );
  }

  static Future<void> showVIPModal(
      BuildContext context, Function callback) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VIPCongratsModal(callback: callback),
    );
  }
}

class VIPCongratsModal extends StatefulWidget {
  final Function callback;
  const VIPCongratsModal({Key? key, required this.callback}) : super(key: key);

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
    _setupAnimations();
    _startCountdown();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      setState(() {
        _countdown--;
      });

      if (_countdown <= 0) {
        timer.cancel();
        _closeModal();
        widget.callback();
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
            constraints: const BoxConstraints(maxWidth: 320),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD700), // Gold
                  Color(0xFFFFA500), // Orange gold
                  Color(0xFFFFD700), // Gold
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with gold accent
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.3),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Crown icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(255, 124, 124, 124)
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          size: 32,
                          color: Color(0xFFFFD700), // Gold
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: Column(
                    children: [
                      // Title

                      const Text(
                        'Selamat!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      const Text(
                        'Anda Sekarang VIP',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Timer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255)
                                          .withOpacity(0.8),
                                  blurRadius: 6,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Menutup dalam $_countdown detik',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
