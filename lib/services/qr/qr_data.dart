import 'dart:convert';

class QRData {
  final String userEmail;
  /* final String imageBase64;  */

  QRData({required this.userEmail, /* required this.imageBase64 */});

  // Encode the data into a JSON string
  String toJson() {
    return jsonEncode({
      'User email:' : userEmail,
     // 'imageBase64': imageBase64,
    });
  }
}