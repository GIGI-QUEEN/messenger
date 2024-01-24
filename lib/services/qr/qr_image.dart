import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'qr_data.dart';
// import 'dart:convert';
// import 'dart:typed_data';

class QRImage extends StatelessWidget {
  final QRData data;

  const QRImage(this.data, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Uint8List imageBytes = base64Decode(data.imageBase64);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter + QR code'),
        centerTitle: true,
      ),
      body: Center(
        child: QrImageView(
          data: data.toJson(),
          /* embeddedImage: MemoryImage(imageBytes),
          embeddedImageStyle: const QrEmbeddedImageStyle(
            size: Size(80, 80),
          ), */
          version: QrVersions.auto,
          size: 200.0,
        ),
      ),
    );
  }
}
