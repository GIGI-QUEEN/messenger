// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:secure_messenger/services/qr/qr_image.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../auth/auth_service.dart';
import 'qr_data.dart';
import 'dart:convert';
import 'dart:typed_data';

class GenerateQRCode extends StatefulWidget {
  const GenerateQRCode({super.key});

  @override
  GenerateQRCodeState createState() => GenerateQRCodeState();
}

class GenerateQRCodeState extends State<GenerateQRCode> {
// chat and auth service
  final AuthService _authService = AuthService();

  Future<String> encodeImageToBase64(String assetPath) async {
    // Read the image file from the asset bundle
    ByteData data = await rootBundle.load(assetPath);
    List<int> imageBytes = data.buffer.asUint8List();

    // Encode image bytes to Base64
    String imageBase64 = base64Encode(imageBytes);

    return imageBase64;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter + QR code'),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //this button when pressed navigates to QR code generation
          Center(
            child: ElevatedButton(
                onPressed: () async {
                  String? currentUserEmail =
                      _authService.getCurrentUser()?.email;

                  if (currentUserEmail != null) {
                    // Encode image data (you need to replace this with your logic)
                   /*  String imageBase64 =
                        await encodeImageToBase64('assets/images/image.png'); */

                    final QRData qrData = QRData(
                      userEmail: currentUserEmail,
                      //imageBase64: imageBase64,
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) {
                          return QRImage(qrData);
                        }),
                      ),
                    );
                  }
                },
                child: const Text('GENERATE QR CODE')),
          ),
        ],
      ),
    );
  }
}
