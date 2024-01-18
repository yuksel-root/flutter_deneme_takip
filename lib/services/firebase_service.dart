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

  Future<Map<String, List<dynamic>>?> getPostDataByUser(String userId) async {
    try {
      final userDoc = await usersCollection.doc(userId).get();
      Map<String, dynamic>? postData = userDoc.data();

      Map<String, List<dynamic>>? postModels = {
        DenemeTables.historyTableName: postData?['denemePosts']
            [DenemeTables.historyTableName]['tableData'],
        DenemeTables.geographyTable: postData?['denemePosts']
            [DenemeTables.geographyTable]['tableData'],
        DenemeTables.citizenTable: postData?['denemePosts']
            [DenemeTables.citizenTable]['tableData'],
      };

      return postModels;
    } on FirebaseAuthException catch (error) {
      {
        print("Fs getTable catch $error");
      }
    }
    return null;
  }

  Future<void> sendMultiplePostsToFirebase(String userId) async {
    try {
      List<DenemePostModel> postModels = [];
      final hT = await DenemeDbProvider.db
          .getAllDataByTable(DenemeTables.historyTableName);
      final gT = await DenemeDbProvider.db
          .getAllDataByTable(DenemeTables.geographyTable);
      final cT = await DenemeDbProvider.db
          .getAllDataByTable(DenemeTables.citizenTable);

      postModels = [
        DenemePostModel(
          userId: userId,
          tableName: DenemeTables.historyTableName,
          tableData: hT,
        ),
        DenemePostModel(
          userId: userId,
          tableName: DenemeTables.geographyTable,
          tableData: gT,
        ),
        DenemePostModel(
          userId: userId,
          tableName: DenemeTables.citizenTable,
          tableData: cT,
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
      print("DenemePosts successfully added.");
      await _firestore!
          .collection('users')
          .doc(userId)
          .set({'denemePosts': combinedData}, SetOptions(merge: true));
    } on FirebaseAuthException catch (error) {
      print(
          "---------sendTable FS CATCH ERROR------------------ ${error.message}");
    } catch (e) {
      print('Cathch fS sendTable $e');
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
        print('User succesfully added.');
      } else {
        print('This user already exist');
      }
    } catch (e) {
      print('Add User exception in FirebaseS $e');
    }
  }

  Future<void> deleteUserFromCollection(String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      var userDoc = await firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        await firestore.collection('users').doc(userId).delete();
        print('User successfully deleted.');
      } else {
        print('User not found. Unable to delete.');
      }
    } catch (e) {
      print('Delete User exception in Firebase: $e');
    }
  }
}
