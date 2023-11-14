import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Users.dart';
import 'forms/editUser.dart';

class ManageUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // DateTime now = DateTime.now();
    // String dayName = DateFormat('EEEE').format(now);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    List<Users> items = snapshot.data!.docs
                        .where((doc) => doc['role'] == 'user')
                        .map((doc) {
                      Map<String, dynamic>? user =
                          doc.data() as Map<String, dynamic>?;
                      return Users(
                        id: doc.id,
                        username:
                            user!['username'] != null ? user['username'] : '',
                        role: user!['role'] != null ? user['role'] : '',
                        email: user['email'] != null ? user['email'] : '',
                        phone_no:
                            user['phone_no'] != null ? user['phone_no'] : '',
                        dob: user['dob'] != null ? user['dob'] : '',
                        address: user['address'] != null ? user['address'] : "",
                        expirationStatus: user['expirationStatus'] != null
                            ? user['expirationStatus']
                            : "",
                      );
                    }).toList();

                    // List<Users> items = snapshot.data!.docs.map((doc) {
                    //   Map<String, dynamic>? user =
                    //       doc.data() as Map<String, dynamic>?;
                    //   return Users(
                    //     id: doc.id,
                    //     username:
                    //         user!['username'] != null ? user['username'] : '',
                    //     email: user['email'] != null ? user['email'] : '',
                    //     phone_no:
                    //         user['phone_no'] != null ? user['phone_no'] : '',
                    //     dob: user['dob'] != null ? user['dob'] : '',
                    //     address: user['address'] != null ? user['address'] : '',
                    //   );
                    // }).toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            Text("Users"),
                            DataTable(
                              columns: [
                                DataColumn(label: Text('Id')),
                                DataColumn(label: Text('username')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('phone_no')),
                                DataColumn(label: Text('dob')),
                                DataColumn(label: Text('Address')),
                                DataColumn(label: Text('ExpirationStatus')),
                                // DataColumn(label: Text('Actions')),
                              ],
                              rows: items.map((item) {
                                return DataRow(cells: [
                                  DataCell(Text(item.id)),
                                  DataCell(Text(item.username)),
                                  DataCell(Text(item.email)),
                                  DataCell(Text(item.phone_no)),
                                  DataCell(Text(item.dob)),
                                  DataCell(Text(item.address)),
                                  DataCell(Text(item.expirationStatus)),

                                ]);
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
