import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class PackageForm extends StatefulWidget {
  const PackageForm({Key? key}) : super(key: key);

  @override
  State<PackageForm> createState() => _PackageFormState();
}

class _PackageFormState extends State<PackageForm> {
  String? valueChoose;
  TextEditingController _descriptionTextController = TextEditingController();
  TextEditingController _packageTextController = TextEditingController();
  TextEditingController _durationTextController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference imageCollection =
      FirebaseFirestore.instance.collection('packages');

  XFile? pickedFile;

  Future<XFile?> _pickImage() async {
    final picker = ImagePicker();
    pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    return pickedFile;
  }

  Future<void> _upload() async {
    if (pickedFile == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please pick an image first.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final String fileName = path.basename(pickedFile!.path);
    File file = File(pickedFile!.path);

    try {
      // Show confirmation message
      bool confirmUpload = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Do you want to upload the image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
          ],
        ),
      );

      if (confirmUpload == true) {
        // Uploading the selected image with some custom meta data
        await storage.ref(fileName).putFile(
              file,
              // SettableMetadata(
              //   customMetadata: {
              //     'uploaded_by': 'admin..',
              //   },
              // ),
            );

        final imageUrl = await storage.ref(fileName).getDownloadURL();

        await imageCollection.doc(fileName).set({
          'url': imageUrl,
          'package': _packageTextController.text,
          'description': _descriptionTextController.text,
          'date': DateTime.now(),
          'uploaded_by': 'Admin',
          'duration': _durationTextController.text,
          'price': _priceController.text,
        });

        // Refresh the UI
        setState(() {});
      }
    } on FirebaseException catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
  }

  List<String> listItem = ["Chest", "Abs", "Shoulder", "Triceps"];

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form"),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 55, right: 55),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * 0.05),
            TextFormField(
              controller: _packageTextController,
              decoration: InputDecoration(
                labelText: "Package",
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: const Text(
                        "Category",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Enter Price",
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _durationTextController,
              decoration: InputDecoration(
                labelText: "Enter Duration",
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            TextFormField(
              controller: _descriptionTextController,
              decoration: InputDecoration(
                labelText: "Add description",
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    await _pickImage();
                  },
                  icon: const Icon(Icons.photo_library_sharp),
                  label: const Text('Pick Picture'),
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    _upload();
                  },
                  child: const Text('Save'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/upload');
              },
              child: Text('to upload workout'),
            ),
          ],
        ),
      ),
    );
  }
}
