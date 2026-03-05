import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CryptoService {
  CryptoService._();

  static final CryptoService instance = CryptoService._();

  // AES-GCM is modern + authenticated encryption
  final AesGcm _algo = AesGcm.with256bits();
  final FlutterSecureStorage _secure = const FlutterSecureStorage();

  static const String _keyName = "app_aes256_key_v1";

  /// Call this once early (e.g., in main before runApp)
  Future<void> init() async {
    await _getOrCreateKey();
  }

  Future<SecretKey> _getOrCreateKey() async {
    final existing = await _secure.read(key: _keyName);
    if (existing != null) {
      final bytes = base64Decode(existing);
      return SecretKey(bytes);
    }

    final key = await _algo.newSecretKey();
    final keyBytes = await key.extractBytes();
    await _secure.write(key: _keyName, value: base64Encode(keyBytes));
    return key;
  }

  Uint8List _randomNonce([int length = 12]) {
    final rnd = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rnd.nextInt(256)),
    );
  }

  /// Encrypt a string -> returns a JSON string that contains cipher/nonce/mac
  Future<String> encryptString(String plain) async {
    final key = await _getOrCreateKey();
    final nonce = _randomNonce(12);

    final secretBox = await _algo.encrypt(
      utf8.encode(plain),
      secretKey: key,
      nonce: nonce,
    );

    final payload = <String, String>{
      "c": base64Encode(secretBox.cipherText),
      "n": base64Encode(secretBox.nonce),
      "m": base64Encode(secretBox.mac.bytes),
      "v": "1",
    };

    return jsonEncode(payload);
  }

  /// Decrypt the JSON string produced by encryptString()
  Future<String> decryptString(String payload) async {
    final map = jsonDecode(payload) as Map<String, dynamic>;
    final cipherText = base64Decode(map["c"] as String);
    final nonce = base64Decode(map["n"] as String);
    final macBytes = base64Decode(map["m"] as String);

    final key = await _getOrCreateKey();

    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(macBytes));

    final clearBytes = await _algo.decrypt(secretBox, secretKey: key);

    return utf8.decode(clearBytes);
  }
}
