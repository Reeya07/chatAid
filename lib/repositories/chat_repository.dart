import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_info.dart';

class ChatRepository {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future<void> saveMessage(String uid, Chatinfo message) {
    return _database
        .collection('users')
        .doc(uid)
        .collection('messages')
        .add(message.toMap());
  }

  Stream<List<Chatinfo>> messageStream(String uid) {
    return _database
        .collection('users')
        .doc(uid)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((messagedoc) => Chatinfo.fromMap(messagedoc.data()))
              .toList(),
        );
  }
}
