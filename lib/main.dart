import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'models/Users.dart';
import 'screens/admin_home.dart';
import 'screens/forms/packageUpload.dart';
import 'screens/manageUsers.dart';
import 'screens/packageView.dart';
import 'screens/signin.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  addExpirationStatusToUsers();
  print('Expiration status added to users successfully');
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: '/login',
    routes: {
      '/login': (context) => Signin(),
      '/home': (context) => AdminHome(),
      '/packageForm': (context) => AddPackage(),
      '/packageView': (context) => ViewPackage(),
      '/manageUsers': (context) => ManageUsers(),
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: Signin(),
    );
  }
}
