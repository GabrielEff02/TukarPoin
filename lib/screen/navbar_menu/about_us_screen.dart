import 'package:e_commerce/screen/gabriel/core/app_export.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  String? localPath;
  PdfControllerPinch? _pdfController;

  @override
  void initState() {
    super.initState();
    loadPDF();
  }

  Future<void> loadPDF() async {
    final data = await rootBundle.load("assets/about_us/about_us.pdf");
    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/about_us.pdf");
    await file.writeAsBytes(data.buffer.asUint8List(), flush: true);

    setState(() {
      localPath = file.path;
      _pdfController = PdfControllerPinch(
        document: PdfDocument.openFile(file.path),
      );
    });
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WidgetHelper.appbarWidget(
        function: () => Get.back(),
        Text(
          'About Us',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      ),
      body: localPath == null || _pdfController == null
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: _pdfController!),
    );
  }
}
