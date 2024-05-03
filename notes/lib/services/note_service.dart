import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class NoteService {
  static final FirebaseFirestore _database = FirebaseFirestore.instance;
  static final CollectionReference _notesCollection =
      _database.collection('notes');

  static Future<void> addNote(String title, String description) async {
    Map<String, dynamic> newNote = {'title': title, 'description': description};
    await _notesCollection.add(newNote);
  }

  static Future<void> updateNote(String id, String title, String description) async{
    Map<String, dynamic> updatedNote = {'title': title, 'description': description};
    await _notesCollection.doc(id).update(updatedNote);
  }
  static Future<void> deleteNote(String id) async {
    await _notesCollection.doc(id).delete();
  }

  static Future<QuerySnapshot> retriveNotes(){
    return _notesCollection.get();
  }

  static Stream<List<Map<String, dynamic>>> getNotesList(){
    return _notesCollection.snapshots().map((querySnapshot){
      return querySnapshot.docs.map((docSnapshot){
        final data = docSnapshot.data() as Map<String, dynamic>;
        return{'id': docSnapshot.id, ...data};
      }).toList();
    });
    }
  }

