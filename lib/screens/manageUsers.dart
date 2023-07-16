import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NutritionItem {
  String id;
  String foodTime;
  String food;
  String category;
  String day;
  int calories;

  NutritionItem(
      {required this.id,
      required this.foodTime,
      required this.food,
      required this.category,
      required this.day,
      required this.calories});
}

class Users {
  String id;
  String username;
  String email;
  String phone_no;
  String dob;
  String address;

  Users({
    required this.id,
    required this.username,
    required this.email,
    required this.phone_no,
    required this.dob,
    required this.address,
  });
}

class ManageUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String dayName = DateFormat('EEEE').format(now);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('nutrition_chart')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                print(dayName);
                // List<NutritionItem> items = snapshot.data!.docs.map((doc) {
                List<NutritionItem> items = snapshot.data!.docs
                    .where((doc) =>
                        doc['day'] == dayName &&
                        doc['category'] == 'Overweight')
                    .map((doc) {
                  Map<String, dynamic>? data =
                      doc.data() as Map<String, dynamic>?;
                  return NutritionItem(
                    id: doc.id,
                    foodTime: data!['foodTime'] != null ? data['foodTime'] : '',
                    food: data['food'] != null ? data['food'] : '',
                    category: data['category'] != null ? data['category'] : '',
                    day: data['day'] != null ? data['day'] : '',
                    calories: data['calories'] != null ? data['calories'] : 0,
                  );
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Food Time')),
                      DataColumn(label: Text('Food')),
                      DataColumn(label: Text('Calories')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Day')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: items.map((item) {
                      return DataRow(cells: [
                        DataCell(Text(item.foodTime)),
                        DataCell(Text(item.food)),
                        DataCell(Text(item.calories.toString())),
                        DataCell(Text(item.category.toString())),
                        DataCell(Text(item.day.toString())),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Handle edit functionality
                                // You can navigate to a new screen or show a dialog to edit the nutrition item data
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Handle delete functionality
                                // You can show a confirmation dialog and delete the nutrition item from Firestore
                              },
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
