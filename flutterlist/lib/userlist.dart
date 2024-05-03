import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutterlist/firebase_service.dart';
import 'package:flutterlist/userdata.dart';
import 'package:flutterlist/useritem.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:developer';

class UserList extends StatefulWidget {
  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  FirebaseService firebaseService = new FirebaseService();

  TextEditingController nama = TextEditingController();

  TextEditingController npm = TextEditingController();

  TextEditingController email = TextEditingController();

  List<UserData> daftarUser = [];

  Color btnSimpanColorDefault = Colors.blue;
  Color btnSimpanColor = Colors.blue;
  Color btnUbahColor = Colors.blueGrey;
  String btnSimpanTextDefault = "Simpan";
  String btnSimpanText = "Simpan";
  String btnUbahText = "Ubah";

  bool isReadOnly = false;

  int selectedDaftarUserIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Container(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(5),
              child: TextField(
                controller: nama,
                readOnly: isReadOnly,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Nama", border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: TextField(
                controller: npm,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "NPM", border: OutlineInputBorder()),
              ),
            ),
            Container(
              padding: EdgeInsets.all(5),
              child: TextField(
                controller: email,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Email", border: OutlineInputBorder()),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  child: ElevatedButton(
                    onPressed: () {
                      try {
                        if (nama.text.isEmpty ||
                            npm.text.isEmpty ||
                            email.text.isEmpty)
                          throw ("Data tidak boleh kosong");

                        if (btnSimpanText == btnSimpanTextDefault) {
                          // INI MENUNJUKAN SAVE
                          UserData userData = new UserData(
                              nama.text, int.parse(npm.text), email.text);
                          firebaseService.tambah(userData);
                          //daftarUser.add(UserData(nama.text, int.parse(npm.text), email.text));
                        } else {
                          UserData userData = new UserData(
                              nama.text, int.parse(npm.text), email.text);
                          firebaseService.ubah(userData);

                          btnSimpanColor = btnSimpanColorDefault;
                          btnSimpanText = btnSimpanTextDefault;
                          setState(() {
                            btnSimpanColor;
                            btnSimpanText;
                          });
                        }

                        setState(() {
                          isReadOnly = false;
                        });

                        nama.text = "";
                        npm.text = "";
                        email.text = "";
                      } catch (e) {
                        Fluttertoast.showToast(msg: '$e');
                      }
                    },
                    child: Text(btnSimpanText),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: btnSimpanColor,
                      minimumSize: Size(150, 75),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(5),
                  child: ElevatedButton(
                    onPressed: () {
                      nama.text = "";
                      npm.text = "";
                      email.text = "";
                      btnSimpanColor = btnSimpanColorDefault;
                      btnSimpanText = btnSimpanTextDefault;
                      setState(() {
                        btnSimpanColor;
                        btnSimpanText;
                        false;
                      });
                    },
                    child: Text("Clear"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: Size(150, 75),
                    ),
                  ),
                ),
              ],
            ),
            Divider(
              height: 20,
              thickness: 3,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: firebaseService.ambilData(),
                  builder: (context, snapshot) {
                    return ListView.separated(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          DocumentSnapshot documentSnapshot =
                              snapshot.data!.docs[index];
                          UserData userData = new UserData(
                              documentSnapshot['nama'],
                              documentSnapshot['npm'],
                              documentSnapshot['email']);
                          return Dismissible(
                            key: ValueKey(userData),
                            child: InkWell(
                              child: UserItem(userData),
                              onTap: () {
                                nama.text = userData.nama;
                                npm.text = userData.npm.toString();
                                email.text = userData.email;
                                btnSimpanColor = btnUbahColor;
                                btnSimpanText = btnUbahText;
                                isReadOnly = true;
                                setState(() {
                                  btnSimpanColor;
                                  btnSimpanText;
                                  isReadOnly;
                                });
                                selectedDaftarUserIndex = index;
                              },
                            ),
                            background: Container(
                              padding: EdgeInsets.only(left: 25),
                              color: Colors.red,
                              child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  )),
                            ),
                            secondaryBackground: Container(
                              color: Colors.white,
                            ),
                            dismissThresholds: {
                              DismissDirection.startToEnd: 0.2
                            },
                            //HAPUS
                            onDismissed: (direction) {
                              firebaseService.hapus(userData);
                              // daftarUser.removeAt(index);
                              //   setState(() {
                              //     daftarUser;
                              // });
                              // inspect(daftarUser);
                            },
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.startToEnd) {
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text("Confirm"),
                                      content: const Text(
                                          "Are you sure you wish to delete this item?"),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text("DELETE")),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(false),
                                          child: const Text("CANCEL"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                return false;
                              }
                            },
                          );
                        },
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: snapshot.data!.docs.length);
                  }),
            ),
          ],
        ),
      ),
    ));
  }
}
