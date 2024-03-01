import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:secure_messenger/services/encryption/encryption_serivce.dart';

class AuthService {
  // instance of auth
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EncryptionService _encryption = EncryptionService();
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  static Future<bool> authenticateUser() async {
    final LocalAuthentication localAuthentication = LocalAuthentication();

    bool isAuthenticated = false;
    bool isBiometricSupported = await localAuthentication.isDeviceSupported();
    bool canCheckBiometrics = await localAuthentication.canCheckBiometrics;

    if (isBiometricSupported && canCheckBiometrics) {
      try {
        isAuthenticated = await localAuthentication.authenticate(
            localizedReason: 'Scan your fingerprint to authenticate',
            options: const AuthenticationOptions(
              biometricOnly: true,
              useErrorDialogs: true,
              stickyAuth: true,
            ));
      } on PlatformException catch (e) {
        log(e as String);
      }
    }
    return isAuthenticated;
  }

  // sign in
  Future<UserCredential?> signInWithEmailPassword(
      String email, password, Function wrongCredentialsMessage) async {
    try {
      // sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential' || e.code == 'invalid-email') {
        log('Invalid credentials');
        wrongCredentialsMessage();
      }
      log('Error logging in');
      // todo: notify user of error
      log(e.code);
      wrongCredentialsMessage();
      return null;
    }
  }

  // sign up
  Future<void> signUpWithEmailPassword(String email, password, username) async {
    try {
      final AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair =
          _encryption.generateRSAkeyPair(_encryption.exampleSecureRandom());
      // create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _encryption.saveKeyPairToDeviceStorage(userCredential.user!.uid, keyPair);
      final encodedKeyPair = _encryption.encodeKeyPairToString(keyPair);

      await FirebaseChatCore.instance.createUserInFirestore(
          types.User(id: userCredential.user!.uid, metadata: {
        "email": userCredential.user!.email,
        "username": username,
        "publicKey": encodedKeyPair['publicKey'],
        // "privateKey": encodedKeyPair['privateKey'],
      }));

      //return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign out
  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // errors
}
