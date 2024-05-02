import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterlist/userdata.dart';

class FirebaseService {
  static final COLLECTION_REF = 'user';

  final firestore = FirebaseFirestore.instance;
  late final CollectionReference userRef;

  FirebaseService() {
    userRef = firestore.collection(COLLECTION_REF);
  }

  void tambah(UserData userData) {
    DocumentReference documentReference = userRef.doc(userData.nama);
    documentReference.set(userData.toJson());
  }
}
