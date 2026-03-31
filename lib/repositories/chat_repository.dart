import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_info.dart';
import '../services/encrypt.dart';

class ChatRepository {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> saveMessage(String uid, Chatinfo message) async {
    final textEnc = await CryptoService.instance.encryptString(message.text);

    final data = {
      'role': message.role,
      'textEnc': textEnc,
      'emotionEnc': message.emotion == null
          ? null
          : await CryptoService.instance.encryptString(message.emotion!),
      'scoreEnc': message.score == null
          ? null
          : await CryptoService.instance.encryptString(
              message.score!.toString(),
            ),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _database
        .collection('users')
        .doc(uid)
        .collection('messages')
        .add(data);
  }

  Stream<List<Chatinfo>> messageStream(String uid) {
    return _database
        .collection('users')
        .doc(uid)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .asyncMap((snapshot) async {
          final List<Chatinfo> list = [];

          for (final doc in snapshot.docs) {
            final data = doc.data();

            final String text = await CryptoService.instance.decryptString(
              (data['textEnc'] ?? '') as String,
            );

            final String? emotion = (data['emotionEnc'] == null)
                ? null
                : await CryptoService.instance.decryptString(
                    data['emotionEnc'] as String,
                  );

            final double? score = (data['scoreEnc'] == null)
                ? null
                : double.tryParse(
                    await CryptoService.instance.decryptString(
                      data['scoreEnc'] as String,
                    ),
                  );

            list.add(
              Chatinfo(
                role: (data['role'] ?? 'user') as String,
                text: text,
                emotion: emotion,
                score: score,
                createdAt: data['createdAt'] as Timestamp?,
              ),
            );
          }

          return list;
        });
  }
}
