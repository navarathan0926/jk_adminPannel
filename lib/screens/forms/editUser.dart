import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUser extends StatefulWidget {
  final String username;
  final String id;
  final String email;
  final String role;
  final String phone_no;
  final String dob;
  final String address;
  final String expirationStatus;

  EditUser({
    required this.username,
    required this.id,
    required this.email,
    required this.role,
    required this.phone_no,
    required this.dob,
    required this.address,
    required this.expirationStatus,
  });

  @override
  _EditUserState createState() => _EditUserState();
}

class _EditUserState extends State<EditUser> {
  late TextEditingController _nameController;
  late TextEditingController _idController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _phone_noController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _expirationStatusController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.username);
    _idController = TextEditingController(text: widget.id);
    _emailController = TextEditingController(text: widget.email);
    _roleController = TextEditingController(text: widget.role);
    _phone_noController = TextEditingController(text: widget.phone_no);
    _dobController = TextEditingController(text: widget.dob);
    _addressController = TextEditingController(text: widget.address);
    _expirationStatusController =
        TextEditingController(text: widget.expirationStatus);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _updateUser() {
    String newName = _nameController.text;
    String newId = _idController.text;
    String newEmail = _emailController.text;
    String newRole = _roleController.text;
    String newPhone_no = _phone_noController.text;
    String newDob = _dobController.text;
    String newAddress = _addressController.text;
    String newExpirationStatus = _expirationStatusController.text;

    // Update the user data in Firestore
    FirebaseFirestore.instance.collection('users').doc(widget.id).update({
      'username': newName,
      'id': newId,
      'email': newEmail,
      'role': newRole,
      'phone_no': newPhone_no,
      'dob': newDob,
      'address': newAddress,
      'expirationStatus': newExpirationStatus,
    }).then((value) {
      // Update successful
      Navigator.pushReplacementNamed(context, '/manageUsers');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User updated successfully')),
      );
    }).catchError((error) {
      // Update failed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _idController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'ID',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _phone_noController,
              decoration: InputDecoration(
                labelText: 'Phone No',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _roleController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Role',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _dobController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'DOB',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Address',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _expirationStatusController,
              decoration: InputDecoration(
                labelText: 'Expiration Status',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _updateUser,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
