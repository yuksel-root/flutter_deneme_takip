// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_deneme_takip/core/local_database/exam_db_provider.dart';

import 'package:flutter_deneme_takip/models/exam_post_model.dart';

class FirebaseService {
  late FirebaseFirestore? _firestore;
  FirebaseService() {
    _firestore = FirebaseFirestore.instance;
  }

  final usersCollection = FirebaseFirestore.instance.collection('users');

  Future<Map<String, List<dynamic>>?> getPostDataByUser(String userId) async {
    Map<String, List<dynamic>> postModels = {};
    try {
      final postData =
          await usersCollection.doc(userId).get().then((querySnapshot) {
        if (querySnapshot.exists && !querySnapshot.metadata.isFromCache) {
          return querySnapshot.data();
        } else {
          return null;
        }
      });
      if (postData!['examPosts'] != null) {
        /*  postModels = {
          examTables.historyTableName: postData['examPosts']
              [examTables.historyTableName]['tableData'],
          examTables.geographyTable: postData['examPosts']
              [examTables.geographyTable]['tableData'],
          examTables.citizenTable: postData['examPosts']
              [examTables.citizenTable]['tableData'],
        }; */

        return postModels;
      }
    } catch (error) {
      {
        print("Fs getTable catch $error");
      }
    }
    return postModels;
  }

  Future<Map<String, dynamic>?> isFromCache(String userId) async {
    Map<String, dynamic>? postData;
    try {
      postData = await usersCollection.doc(userId).get().then((querySnapshot) {
        if (querySnapshot.exists && !querySnapshot.metadata.isFromCache) {
          return querySnapshot.data();
        } else {
          return null;
        }
      });
    } catch (e) {
      print("isFrom cache catch $e");
    }
    return postData;
  }

  Future<void> removeUserPostData(String userId) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        if (userData.containsKey('examPosts')) {
          await firestore.collection('users').doc(userId).update({
            'examPosts': FieldValue.delete(),
          });

          print('Belge başarıyla silindi: ');
        } else {
          print('Belirtilen tablo bulunamadı veya zaten silinmiş.');
        }
      } else {
        print('Kullanıcı belgesi bulunamadı.');
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  Future<void> sendMultiplePostsToFirebase(String userId) async {
    List<ExamPostModel> postModels = [];
    /*  final hT = await examDbProvider.db
        .getAllDataByTable(examTables.historyTableName);
    final gT = await examDbProvider.db
        .getAllDataByTable(examTables.geographyTable);
    final cT =
        await examDbProvider.db.getAllDataByTable(examTables.citizenTable);

    postModels = [
      examPostModel(
        userId: userId,
        tableName: examTables.historyTableName,
        tableData: hT,
      ),
      examPostModel(
        userId: userId,
        tableName: examTables.geographyTable,
        tableData: gT,
      ),
      examPostModel(
        userId: userId,
        tableName: examTables.citizenTable,
        tableData: cT,
      ),
    ]; */

    Map<String, dynamic> combinedData = {};

    try {
      for (var postModel in postModels) {
        combinedData[postModel.tableName] = {
          'userId': postModel.userId,
          'tableData': postModel.tableData,
          'tableName': postModel.tableName,
        };
      }

      await _firestore!
          .collection('users')
          .doc(userId)
          .set({'examPosts': combinedData}, SetOptions(merge: true));
    } catch (e) {
      print('Cathch fS sendTable $e');
    }
  }

  Future<void> addUserToCollection(
      String name, String email, String userId) async {
    try {
      final userDoc = await _firestore!.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        await _firestore!.collection('users').doc(userId).set({
          'examUser': {
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
      final userDoc = await _firestore!.collection('users').doc(userId).get();

      if (userDoc.exists) {
        await _firestore!.collection('users').doc(userId).delete();
        print('User successfully deleted.');
      } else {
        print('User not found. Unable to delete.');
      }
    } catch (e) {
      print('Delete User exception in Firebase: $e');
    }
  }
}
