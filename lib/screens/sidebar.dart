import 'package:flutter/material.dart';

class SideBar extends StatelessWidget {
  final String currentPage;
  final Function(String) onNavigationChanged;

  SideBar({required this.currentPage, required this.onNavigationChanged});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black87,
        child: ListView(
          children: [
            DrawerHeader(
              child: Center(
                child: Text(
                  'Gym Management System',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            _createNavItem(
              title: 'Package View',
              route: '/packageView',
            ),
            _createNavItem(
              title: 'Manage Coach',
              route: '/manageCoach',
            ),
            _createNavItem(
              title: 'Inventory Manage',
              route: '/inventoryManage',
            ),
            _createNavItem(
              title: 'Payment Show',
              route: '/paymentShow',
            ),
            _createNavItem(
              title: 'Manage Users',
              route: '/manageUsers',
            ),
          ],
        ),
      ),
    );
  }

  Widget _createNavItem({required String title, required String route}) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(color: Colors.white),
      ),
      selected: currentPage == route,
      onTap: () {
        onNavigationChanged(route);
      },
    );
  }
}
