import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';
import 'package:pointycastle/api.dart' as crypto;
import 'package:pointycastle/src/platform_check/platform_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EncryptionService {
  /// Saving user's key pair to device storage
  void saveKeyPairToDeviceStorage(String userId,
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair) async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    _setPrivateKey(userId, keyPair.privateKey, prefs);
    _setPublicKey(userId, keyPair.publicKey, prefs);
  }

  /// Set user's private key to storage
  void _setPrivateKey(
      String userId, RSAPrivateKey privateKey, SharedPreferences prefs) async {
    final privateKeyAsString =
        CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(privateKey);
    await prefs.setString('${userId}_privateKey', privateKeyAsString);
  }

  /// Set user's public key to storage
  void _setPublicKey(
      String userId, RSAPublicKey publicKey, SharedPreferences prefs) async {
    final publicKeyAsString =
        CryptoUtils.encodeRSAPublicKeyToPemPkcs1(publicKey);
    await prefs.setString('${userId}_publicKey', publicKeyAsString);
  }

  /// Get user's private key
  Future<String> getPrivateKey(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('${userId}_privateKey')!;
  }

  /// Get user's public key
  Future<String> getPublicKey(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('${userId}_publicKey')!;
  }

  /// For testing purposes only
  Map<String, String> encodeKeyPairToString(
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair) {
    final privateKeyAsString =
        CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(keyPair.privateKey);
    final publicKeyAsString =
        CryptoUtils.encodeRSAPublicKeyToPemPkcs1(keyPair.publicKey);
    return {
      'publicKey': publicKeyAsString,
      'privateKey': privateKeyAsString,
    };
  }

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
      SecureRandom secureRandom,
      {int bitLength = 2048}) {
    // Create an RSA key generator and initialize it

    // final keyGen = KeyGenerator('RSA'); // Get using registry
    final keyGen = RSAKeyGenerator();

    keyGen.init(ParametersWithRandom(
        RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
        secureRandom));

    // Use the generator

    final pair = keyGen.generateKeyPair();

    // Cast the generated key pair into the RSA key types

    final myPublic = pair.publicKey as RSAPublicKey;
    final myPrivate = pair.privateKey as RSAPrivateKey;

    return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
  }

  encrypt.Encrypted encryptMessage(
      String message, String publicKey, String privateKey) {
    final public = CryptoUtils.rsaPublicKeyFromPemPkcs1(publicKey);
    final private = CryptoUtils.rsaPrivateKeyFromPemPkcs1(privateKey);

    final encrypter =
        encrypt.Encrypter(encrypt.RSA(publicKey: public, privateKey: private));
    return encrypter.encrypt(message);
  }

  String decryptMessage(
      encrypt.Encrypted encryptedMessage, String publicKey, String privateKey) {
    final public = CryptoUtils.rsaPublicKeyFromPemPkcs1(publicKey);
    final private = CryptoUtils.rsaPrivateKeyFromPemPkcs1(privateKey);
    final encrypter =
        encrypt.Encrypter(encrypt.RSA(publicKey: public, privateKey: private));

    return encrypter.decrypt(encryptedMessage);
  }

  SecureRandom exampleSecureRandom() {
    final secureRandom = SecureRandom('Fortuna')
      ..seed(
          KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
    return secureRandom;
  }
}
