import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QRCodeCreateWidget extends StatefulWidget {
  const QRCodeCreateWidget({Key? key}) : super(key: key);

  @override
  QRCodeWidgetState createState() => QRCodeWidgetState();
}

class QRCodeWidgetState extends State<QRCodeCreateWidget> {
  final currentUser = FirebaseAuth.instance.currentUser!;
late QrImageView qrCodeImage = QrImageView(data: '', size: 200, gapless: true);

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  Future<void> _generateQRCode() async {
    String userEmail = await _getUserEmail();
    log('User email: $userEmail');
    qrCodeImage = await _generateQRCodeImage(userEmail);
    setState(() {});
  }

  Future<String> _getUserEmail() async {
    return currentUser.email ?? 'Unknown email';
  }

  Future<QrImageView> _generateQRCodeImage(String data) async {
    return QrImageView(
      data: data,
      size: 200,
      gapless: true,
      errorStateBuilder: (context, error) {
        return const Center(
          child: Text(
            'Something went wrong',
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: RepaintBoundary(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(child: qrCodeImage),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 40.0),
                child: Text(
                  'Your QR code is private. If you share it with someone, they can scan it with their Secure-Messenger camera to add you as a contact.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
