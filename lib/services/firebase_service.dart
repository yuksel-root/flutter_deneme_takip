// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_deneme_takip/models/deneme_post_model.dart';

class FirebaseService {
  late FirebaseFirestore? _firestore;
  FirebaseService() {
    _firestore = FirebaseFirestore.instance;
  }

  final usersCollection = FirebaseFirestore.instance.collection('users');

  Future<DenemePostModel> getDataByUsers(String userId) async {
    final userDoc = await usersCollection.doc(userId).get();
    Map<String, dynamic>? postData = userDoc.data();

    final postModel = DenemePostModel.fromJson(postData ?? {});
    return postModel;
  }

  Future<void> insertDenemePostModel(DenemePostModel denemePostModel) async {
    try {
      await _firestore!.collection('denemePosts').add({
        'id': denemePostModel.userId,
        'tableName': denemePostModel.tableName,
        'tableData': denemePostModel.tableData,
      });
      print('DenemePostModel added successfully!');
    } catch (e) {
      print('Error adding DenemePostModel: $e');
    }
  }

  Future<void> addUserToCollection(
      String name, String email, String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Önce kullanıcının var olup olmadığını kontrol et
      var userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        await firestore.collection('users').doc(userId).set({
          'name': name,
          'email': email,
          // Diğer alanları buraya ekleyebilirsiniz
        });
        print('Kullanıcı başarıyla eklendi!');
      } else {
        print('Bu kullanıcı zaten var!');
      }
    } catch (e) {
      print('Kullanıcı eklenirken hata oluştu: $e');
    }
  }
}
