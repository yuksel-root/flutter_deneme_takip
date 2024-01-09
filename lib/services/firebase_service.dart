// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_db_provider.dart';
import 'package:flutter_deneme_takip/core/local_database/deneme_tables.dart';
import 'package:flutter_deneme_takip/models/deneme_post_model.dart';

class FirebaseService {
  late FirebaseFirestore? _firestore;
  FirebaseService() {
    _firestore = FirebaseFirestore.instance;
  }

  final usersCollection = FirebaseFirestore.instance.collection('users');

  Future<DenemePostModel?> getTableDataByUsers(
      String userId, String tableName) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      Map<String, dynamic>? postData = userDoc.data();

      final postModel =
          DenemePostModel.fromJson(postData?['denemePosts'][tableName]);
      return postModel;
    } catch (e) {
      print("Fs getTable catch $e");
    }
    return null;
  }

  Future<void> sendMultiplePostsToFirebase(String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      List<DenemePostModel> postModels = [];
      postModels = [
        DenemePostModel(
          userId: userId,
          tableName: DenemeTables.historyTableName,
          tableData: await DenemeDbProvider.db
              .getLessonDeneme(DenemeTables.historyTableName),
        ),
        DenemePostModel(
          userId: userId,
          tableName: DenemeTables.geographyTable,
          tableData: await DenemeDbProvider.db
              .getLessonDeneme(DenemeTables.geographyTable),
        ),
        DenemePostModel(
          userId: userId,
          tableName: DenemeTables.citizenTable,
          tableData: await DenemeDbProvider.db
              .getLessonDeneme(DenemeTables.citizenTable),
        ),
      ];

      Map<String, dynamic> combinedData = {};

      for (var postModel in postModels) {
        combinedData[postModel.tableName] = {
          'userId': postModel.userId,
          'tableData': postModel.tableData,
          'tableName': postModel.tableName,
        };
      }

      await firestore
          .collection('users')
          .doc(userId)
          .set({'denemePosts': combinedData}, SetOptions(merge: true));
    } on FirebaseAuthException catch (error) {
      return print(
          "---------sendTable FS CATCH ERROR------------------ ${error.message}");
    } catch (e) {
      return print('Cathch fS sendTable $e');
    }
  }

  Future<void> addUserToCollection(
      String name, String email, String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      var userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        await firestore.collection('users').doc(userId).set({
          'denemeUser': {
            'name': name,
            'email': email,
          }
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
