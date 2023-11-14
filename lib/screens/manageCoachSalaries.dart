import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCoachSalaries extends StatefulWidget {
  @override
  ManageCoachSalariesState createState() => ManageCoachSalariesState();
}

class ManageCoachSalariesState extends State<ManageCoachSalaries> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coach Salaries'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('coachSalary').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          List<DataRow> rows = [];

          for (QueryDocumentSnapshot doc in snapshot.data!.docs) {
            Map<String, dynamic>? coachData = doc.data() as Map<String, dynamic>?;
            String coachName = coachData!['username'] ?? '';

            // Iterate through subcollections (monthly data)
            QuerySnapshot monthlyDataSnapshot =  doc.reference.collection('monthSalary').get() as QuerySnapshot<Object?>;
            for (QueryDocumentSnapshot monthDoc in monthlyDataSnapshot.docs) {
              Map<String, dynamic>? monthData = monthDoc.data() as Map<String, dynamic>?;
              String month = monthData!['month'] ?? '';
              double salary = monthData!['Salary '] ?? 0.0;

              rows.add(DataRow(cells: [
                DataCell(Text(coachName)),
                DataCell(Text(month)),
                DataCell(Text(salary.toString())),
              ]));
            }
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Coach Name')),
                  DataColumn(label: Text('Month')),
                  DataColumn(label: Text('Salary')),
                ],
                rows: rows,
              ),
            ),
          );
        },
      ),
    );
  }
}
