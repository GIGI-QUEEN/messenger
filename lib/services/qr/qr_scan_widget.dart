import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:secure_messenger/services/database/database_service.dart';
import 'package:vibration/vibration.dart';

class QRCodeScanWidget extends StatefulWidget {
  const QRCodeScanWidget({Key? key}) : super(key: key);

  @override
  State<QRCodeScanWidget> createState() => QRCodeWidgetState();
}

class QRCodeWidgetState extends State<QRCodeScanWidget> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool hasVibrated = false;

  final DatabaseService _databaseService = DatabaseService();
  final FirebaseChatCore _firebaseChatCore = FirebaseChatCore.instance;

  Future<String> findUser(String email) async {
    final userId = await _databaseService.getUserByUsernameOrEmail(email);
    if (userId != null) {
      log('user: $userId');
      return userId;
    } else {
      log('user NOT FOUND');
      return '';
    }
  }

  void addToContacts(String contactId) {
    _databaseService.addUserToContacts(
        _firebaseChatCore.firebaseUser!.uid, contactId);
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    Platform.isAndroid ? controller?.pauseCamera() : controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? _buildUserFoundNotification(context)
                  : const Text('Scan a code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      _vibrateOnceIfNotVibrated();
    });
  }

  void _vibrateOnceIfNotVibrated() async {
    // vibrate if not already vibrated
    if (!hasVibrated) {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != null && hasVibrator) {
        Vibration.vibrate(duration: 100);
        hasVibrated = true;
      }
    }
  }

  Widget _buildUserFoundNotification(BuildContext context) {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '${result!.code}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            ElevatedButton(
              onPressed: () async {
                // add user to contacts
                String userId = await findUser(result!.code.toString());
                if (userId.isNotEmpty) addToContacts(userId);
                
                // db, add contact
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${result!.code} added to contacts')),
                );
                Future.delayed(const Duration(seconds: 1), () {
                  Navigator.pop(context);
                });
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
