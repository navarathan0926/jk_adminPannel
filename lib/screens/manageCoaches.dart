import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/Coaches.dart';
import '../models/Users.dart';
import '../models/coachSalary.dart';
import 'coachSalaryView.dart';
import 'forms/editCoach.dart';
import 'forms/editUser.dart';

class ManageCoaches extends StatelessWidget {
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

                    List<Coaches> items = snapshot.data!.docs
                        .where((doc) => doc['role'] == 'coach')
                        .map((doc) {
                      Map<String, dynamic>? user = doc.data() as Map<String, dynamic>?;
                      return Coaches(
                        id: doc.id,
                        username: user!['username'] != null ? user['username'] : '',
                        role: user!['role'] != null ? user['role'] : '',
                        email: user['email'] != null ? user['email'] : '',
                        phone_no: user['phone_no'] != null ? user['phone_no'] : '',
                        address: user['address'] != null ? user['address'] : '',
                        trainedusers: user['trainedUsers'] != null
                            ? List<String>.from(user['trainedUsers'])
                            : [], // Ensure it's an empty list if not present or null.
                      );
                    }).toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            Text("Coaches"),
                            DataTable(
                              columns: [
                                DataColumn(label: Text('Id')),
                                DataColumn(label: Text('username')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('phone_no')),
                                DataColumn(label: Text('Address')),
                                DataColumn(label: Text('TrainedUsers')),
                                DataColumn(label: Text('View Salaries')),
                                // DataColumn(label: Text('Actions')),
                              ],
                              rows: items.map((item) {
                                return DataRow(cells: [
                                  DataCell(Text(item.id)),
                                  DataCell(Text(item.username)),
                                  DataCell(Text(item.email)),
                                  DataCell(Text(item.phone_no)),
                                  DataCell(Text(item.address)),
                                  DataCell(Text(item.trainedusers.join(', '))),
                                  DataCell(
                                   ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xff9b1616),
                                  ),
                                     onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => CoachSalaryView(id:item.id),
                                          ));
                                        },
                                     child: Text('View Salaries'),
                                      ),
                                  ),
                                  // DataCell(Row(
                                  //   children: [
                                  //     IconButton(
                                  //       icon: Icon(Icons.edit),
                                  //       onPressed: () {
                                  //         Navigator.push(
                                  //           context,
                                  //           MaterialPageRoute(
                                  //               builder: (context) => EditCoach(
                                  //                 username: item.username,
                                  //                 id: item.id,
                                  //                 email: item.email,
                                  //                 phone_no: item.phone_no,
                                  //                 address: item.address,
                                  //                 role: item.role,
                                  //
                                  //               )),
                                  //         );
                                  //       },
                                  //     ),
                                  //   ],
                                  // )),
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
