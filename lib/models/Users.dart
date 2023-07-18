import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

class Users {
  String id;
  String username;
  String email;
  String role;
  String phone_no;
  String dob;
  String address;
  String expirationStatus;

  Users({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.phone_no,
    required this.dob,
    required this.address,
    required this.expirationStatus,
  });
}

void addExpirationStatusToUsers() async {
  // Get the current date
  DateTime currentDate = DateTime.now();
  String last = currentDate.toString().split(' ')[0];

  // Calculate the date 2 months ago
  DateTime twoMonthsAgo = currentDate.subtract(Duration(days: 60));

  // Format the two months ago date as a string
  String twoMonthsAgoString = twoMonthsAgo.toString().split(' ')[0];

  // Query users who haven't registered attendance in the last 2 months
  QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
      .instance
      .collection('users')
      .where('role', isEqualTo: 'user')
      .get();

  List<Future<void>> updateFutures = [];

  // Iterate through the users and update their expiration status
  for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
      in querySnapshot.docs) {
    String userId = documentSnapshot.id;

    // Check if the user has any attendance records after two months ago
    QuerySnapshot<Map<String, dynamic>> attendanceSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('attendance')
            // .orderBy('date', descending: true)
            // .limit(1)
            .where('date', isGreaterThan: twoMonthsAgoString)
            .get();

    bool hasAttendance = attendanceSnapshot.docs.isNotEmpty;

    // Update the expiration status for the user
    Future<void> updateFuture = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'expirationStatus': hasAttendance ? 'Active' : 'Expired'});

    updateFutures.add(updateFuture);
  }

  // Wait for all updates to complete
  await Future.wait(updateFutures);
}
