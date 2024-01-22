import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static Future<bool> authenticateUser() async {
    // ignore: no_leading_underscores_for_local_identifiers
    final LocalAuthentication _localAuthentication = LocalAuthentication();

    bool isAuthenticated = false;
    bool isBiometricSupproted = await _localAuthentication.isDeviceSupported();
    bool canCheckBiometrics = await _localAuthentication.canCheckBiometrics;

    if (isBiometricSupproted && canCheckBiometrics) {
      try {
        isAuthenticated = await _localAuthentication.authenticate(
            localizedReason: 'Scan your fingerprint to authenticate',
            options: const AuthenticationOptions(
              biometricOnly: true,
              useErrorDialogs: true,
              stickyAuth: false,
            ));
      } on PlatformException catch (e) {
        log(e as String);
      }
    }
    return isAuthenticated;
  }
}
