import 'package:flutter/material.dart';
import 'package:jk_admin/screens/coachSalaryView.dart';
import 'package:jk_admin/screens/manageCoachSalaries.dart';

import 'forms/packageUpload.dart';
import 'manageCoaches.dart';
import 'manageUsers.dart';
import 'packageView.dart';

class Navigation extends StatefulWidget {
  @override
  _NavigationState createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  String _currentPage = 'Add Package';

  void _changePage(String pageName) {
    setState(() {
      _currentPage = pageName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('JK fitness Admin pannel'),
      ),
      body: Row(
        children: [
          // Side Navigation Bar
          Container(
            width: 200,
            color: Colors.black12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNavItem('Add Package'),
                _buildNavItem('View Package'),
                _buildNavItem('Manage Users'),
                _buildNavItem('Manage Coaches'),


              ],
            ),
          ),
          // Content Area
          Expanded(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: _buildPageContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(String title) {
    return InkWell(
      onTap: () => _changePage(title),
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.white),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_currentPage) {
      case 'Add Package':
        return Center(
          child: AddPackage(),
        );
      case 'View Package':
        return Center(
          child: ViewPackage(),
        );
      case 'Manage Users':
        return Center(
          child: ManageUsers(),
        );
      case 'Manage Coaches':
        return Center(
          child: ManageCoaches(),
        );

      default:
        return Center(
          child: Text('404 - Page not found'),
        );
    }
  }
}