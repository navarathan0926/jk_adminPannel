import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:jk_admin/screens/signup.dart';

import '../reusable_widgets/reusable_widgets.dart';
import '../utils/colors.dart';
import 'admin_home.dart';
import 'forgot_pw.dart';

class Signin extends StatefulWidget {
  const Signin({Key? key}) : super(key: key);

  @override
  State<Signin> createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String _userRole = '';
    void navigateToRoleScreen() {
      if (_userRole == 'admin') {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => AdminHome()));
        // Navigator.pushNamed(context, 'coach/coachHome/coachScreen');
      }
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 800.0,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
            ),
            Container(
                width: 800,
                height: MediaQuery.of(context).size.height,
                decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: NetworkImage("assets/images/shoulder.png"),
                      fit: BoxFit.cover,
                    ),
                    gradient: LinearGradient(
                        colors: [Colors.red, Colors.black, Colors.white],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter)),
                child: Container(
                    height: MediaQuery.of(context).size.height - 800.0,
                    width: 500.0,
                    child: Padding(
                        padding: EdgeInsets.only(
                          top: 200,
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          children: <Widget>[
                            // logoWidget("assets/images/fitness.png"),
                            SizedBox(
                              height: 30,
                            ),
                            reusableTextField(
                                "Enter Email",
                                Icons.person_outline,
                                false,
                                _emailTextController),
                            SizedBox(
                              height: 30,
                            ),
                            reusableTextField(
                                "Enter Password",
                                Icons.lock_outline,
                                true,
                                _passwordTextController),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return ForgotPasswordPage();
                                }));
                              },
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            signInSignUpButton(context, true, () {
                              FirebaseAuth.instance
                                  .signInWithEmailAndPassword(
                                      email: _emailTextController.text,
                                      password: _passwordTextController.text)
                                  .then((value) async {
                                String? uid = value.user?.uid;
                                FirebaseFirestore _firestore =
                                    FirebaseFirestore.instance;
                                DocumentSnapshot userSnapshot = await _firestore
                                    .collection('users')
                                    .doc(uid)
                                    .get();

                                // fore role based login
                                if (userSnapshot.exists) {
                                  setState(() {
                                    _userRole = userSnapshot['role'];
                                  });
                                  navigateToRoleScreen();
                                } else {
                                  // Handle user document not found error
                                }

                                // Navigator.push(context,
                                //     MaterialPageRoute(builder: (context) => Home()));
                                _emailTextController.clear();
                                _passwordTextController.clear();
                              }).onError((error, stackTrace) {
                                print("Error ${error.toString()}");
                              });
                            }),
                            singUpOption()
                          ],
                        )))),
          ],
        ),
      ),
    );
  }

  Row singUpOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have account?",
            style: TextStyle(color: Colors.white70)),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => Signup()));
          },
          child: const Text(
            "Sign UP",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
