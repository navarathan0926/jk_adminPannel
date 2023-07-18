import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AddPackage extends StatefulWidget {
  const AddPackage({Key? key}) : super(key: key);

  @override
  State<AddPackage> createState() => _AddPackageState();
}

class _AddPackageState extends State<AddPackage> {
  TextEditingController _packageNameTextController = TextEditingController();
  TextEditingController _durationTextController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference imgCollection =
      FirebaseFirestore.instance.collection('packages');

  html.File? pickedImageFile;
  String? imageUrl;

  void _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        pickedImageFile =
            html.File(result.files.single.bytes!, result.files.single.name);
      });
    }
  }

  Future<void> _upload() async {
    if (pickedImageFile == null) {
      // No file picked, show an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please pick an image file.'),
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

    String fileName = pickedImageFile!.name;
    String filePath = 'package/$fileName';

    // Uploading the selected image with some custom metadata
    final ref = storage.ref().child(filePath);
    final metadata =
        SettableMetadata(contentType: 'image/png', customMetadata: {
      'uploaded_by': 'Admin',
    });
    final uploadTask = ref.putBlob(pickedImageFile!, metadata);
    final snapshot = await uploadTask.whenComplete(() {});
    imageUrl = await snapshot.ref.getDownloadURL();

    try {
      // Show confirmation message
      bool confirmUpload = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Do you want to upload the file?'),
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
        await imgCollection.doc(fileName).set({
          'url': imageUrl,
          'fileName': fileName,
          'packageName': _packageNameTextController.text,
          'date': DateTime.now(),
          'uploaded_by': 'Admin',
          'duration': _durationTextController.text,
          'description': _descriptionController.text,
          'price': _priceController.text,
        });

        // setState(() {});
      }
    } on FirebaseException catch (error) {
      print(error);
    }
  }

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
              controller: _packageNameTextController,
              decoration: InputDecoration(
                labelText: "Package name",
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
            TextFormField(
              controller: _durationTextController,
              decoration: InputDecoration(
                labelText: "Package duration in months",
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: height * 0.05),
            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: "Price",
                labelStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: height * 0.05),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Package description",
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
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
                  onPressed: _upload,
                  child: const Text('Add package'),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/packageView');
              },
              child: Text('to view package'),
            ),
          ],
        ),
      ),
    );
  }
}
