import 'package:flutter/material.dart';

import 'coachSalaryView.dart';
import 'sidebar.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String sideBarSelectedRoute = '/packageView';

  // Rest of the existing code...

  void _onNavigationChanged(String route) {
    setState(() {
      sideBarSelectedRoute = route;
    });
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: SideBar(
        currentPage: sideBarSelectedRoute,
        onNavigationChanged: _onNavigationChanged,
      ),
      body: Center(
        child: Container(

          ),
        ),
    );

  }
}
