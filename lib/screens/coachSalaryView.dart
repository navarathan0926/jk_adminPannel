import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class CoachSalaryView extends StatefulWidget {
  final id;
  CoachSalaryView({this.id});

  @override
  _CoachSalaryState createState() => _CoachSalaryState();
}

class _CoachSalaryState extends State<CoachSalaryView> {
  TextEditingController _oneHourSalaryTextController = TextEditingController();
  double paymentPerHour =0.0;
  String paymentStatus = 'Pending' ;
  String? username;
  String? email;
  List<String>? trainedUsers;
  String? phoneNumber;
  List<CoachSalaryData> coachSalaries = [];



  @override
  void initState() {
    fetchDataAndDisplay(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String? uid;
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    uid = user?.uid;


    return Scaffold(
      appBar: AppBar(
        title: Text('Coach Salary Data'),
      ),
      body: Center(
        child:Column(
          children: [
          TextField(
              controller: _oneHourSalaryTextController,
              decoration: const InputDecoration(
                hintText: 'Enter coach payment per hour',
                hintStyle: TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  paymentPerHour = double.tryParse(value) ?? 0;
                });
              },
            ),

            DropdownButton<String>(
              value: paymentStatus,
              items: <String>['Pending', 'Settled'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  paymentStatus = newValue ?? 'Pending';
                });
              },
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff9b1616),
              ),
              onPressed: () {
                fetchDataAndUpdateFirestore(widget.id);
              },
              child: const Text('Calculate and Update Salary'),
            ),
            DataTable(
              columns: [
                DataColumn(label: Text('Month')),
                DataColumn(label: Text('Salary')),
                DataColumn(label: Text('Working Time')),
                DataColumn(label: Text('Payment Status')),
                DataColumn(label: Text('Total Working Hours By Coach')),
              ],
              rows: coachSalaries.map((salaryData) {
                return DataRow(cells: [
                  DataCell(Text(salaryData.month)),
                  DataCell(Text(salaryData.salary.toStringAsFixed(2))),
                  DataCell(Text(salaryData.workingTime)),
                  DataCell(Text(salaryData.payStatus)),
                  DataCell(Text(salaryData.totalWorkingHoursByCoach.toString())),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> fetchDataAndDisplay(String id)  async {

    var salaryData = await FirebaseFirestore.instance
        .collection('coachSalary')
        .doc(id)
        .collection('monthSalary')
        .get();

    coachSalaries = salaryData.docs.map((doc) {
      var datas = doc.data() as Map<String, dynamic>;
      return CoachSalaryData(
        month: datas['month'],
        salary: (datas['Salary '] as double? ?? 0.0),
        workingTime: datas['workingTime'],
        payStatus: datas['paymentStatus'],
        totalWorkingHoursByCoach: (datas['totalWorkingHoursByCoach'] as int? ?? 0),
      );
    }).toList();

    print('Number of items in coachSalaries: ${coachSalaries.length}');
    setState(() {
      paymentStatus = 'Pending';
    });

  }

  Future<void> fetchDataAndUpdateFirestore(String id) async {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    String formattedFirstDay = DateFormat('yyyy-MM-dd').format(firstDayOfMonth);
    String formattedLastDay = DateFormat('yyyy-MM-dd').format(lastDayOfMonth);
    print(formattedLastDay);
    // var coachIds = coachesSnapshot.docs.map((doc) => doc.id).toList();
    //
    // for (var id in coachIds) {
      var salarySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: formattedFirstDay)
          .where('date', isLessThanOrEqualTo: formattedLastDay)
          .get();

      double totalWorkingHoursByCoach = 0.0;

      salarySnapshot.docs.forEach((salaryDoc) {
        var workingHours = salaryDoc['totalWorkingHours'];
        var timeParts = workingHours.split(':');
        int hours = int.parse(timeParts[0]);
        int minutes = int.parse(timeParts[1]);
        var duration = Duration(hours: hours, minutes: minutes);
        int totalMinutes = duration.inMinutes;
        totalWorkingHoursByCoach += totalMinutes;
      });

      int totalHours = totalWorkingHoursByCoach ~/ 60;
      int remainingMinutes = (totalWorkingHoursByCoach % 60) as int;

      String currentMonth = DateFormat('yyyy-MM').format(DateTime.now());
      var docRef = FirebaseFirestore.instance.collection('coachSalary').doc(id).collection('monthSalary').doc(currentMonth);
     //double coachSalary = (totalWorkingHoursByCoach * paymentPerHour)/60 ;

      double coachSalary = (totalWorkingHoursByCoach * paymentPerHour)/60 ;
      var netWorkingTime ='$totalHours hours $remainingMinutes minutes';
      Map<String, dynamic> data = {
        'month': currentMonth,
        'totalWorkingHoursByCoach': totalWorkingHoursByCoach,
        'workingTime': netWorkingTime,
        'Salary ': (coachSalary / 100).round() * 100,
        'paymentStatus': paymentStatus,
      };
      await docRef.set(data); // Fetch initial data here
      fetchDataAndDisplay(id);
      print('Total Working hours of $id: $totalHours hours $remainingMinutes minutes');
    // }
  }
}
class CoachSalaryData {
  final String month;
  final double salary;
  final String workingTime;
  final String payStatus;
  final int totalWorkingHoursByCoach;

  CoachSalaryData({
    required this.month,
    required this.salary,
    required this.workingTime,
    required this.payStatus,
    required this.totalWorkingHoursByCoach,
  });
}

