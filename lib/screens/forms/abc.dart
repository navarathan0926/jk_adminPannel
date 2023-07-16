import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:video_player/video_player.dart';

class UploadForm extends StatefulWidget {
  const UploadForm({Key? key}) : super(key: key);

  @override
  State<UploadForm> createState() => _UploadFormState();
}

class _UploadFormState extends State<UploadForm> {
  String? valueChoose;
  TextEditingController _instructionTextController = TextEditingController();
  TextEditingController _nameTextController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference imageCollection =
      FirebaseFirestore.instance.collection('images');

  XFile? pickedImageFile;
  File? pickedVideoFile;
  VideoPlayerController? videoController;

  Future<XFile?> _pickImage() async {
    final picker = ImagePicker();
    pickedImageFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    return pickedImageFile;
  }

  Future<File?> _pickVideo() async {
    final picker = ImagePicker();
    pickedVideoFile = File((await picker.pickVideo(
      source: ImageSource.gallery,
    ))!
        .path);
    return pickedVideoFile;
  }

  Future<void> _upload() async {
    if (pickedImageFile == null && pickedVideoFile == null) {
      // No file picked, show an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please pick a file first.'),
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

    String? imageUrl;
    String? videoUrl;
    String? fileName;

    if (pickedImageFile != null) {
      fileName = path.basename(pickedImageFile!.path);
      File imageFile = File(pickedImageFile!.path);

      // Uploading the selected image with some custom metadata
      await storage.ref(fileName).putFile(
            imageFile,
            SettableMetadata(
              customMetadata: {
                'uploaded_by': 'coach..',
              },
            ),
          );

      imageUrl = await storage.ref(fileName).getDownloadURL();
    }

    if (pickedVideoFile != null) {
      fileName = path.basename(pickedVideoFile!.path);
      File videoFile = File(pickedVideoFile!.path);

      // Uploading the selected video with some custom metadata
      await storage.ref(fileName).putFile(
            videoFile,
            SettableMetadata(
              customMetadata: {
                'uploaded_by': 'coach..',
              },
            ),
          );

      videoUrl = await storage.ref(fileName).getDownloadURL();
    }

    // Show confirmation message
    bool? confirmUpload = await showDialog<bool>(
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
      // Upload the file
      if (pickedImageFile != null) {
        final String imageName = path.basename(pickedImageFile!.path);
        File imageFile = File(pickedImageFile!.path);

        // Upload the selected image to Firebase Storage
        await storage.ref(imageName).putFile(
              imageFile,
              SettableMetadata(
                customMetadata: {
                  'uploaded_by': 'coach..',
                },
              ),
            );

        final imageUrl = await storage.ref(imageName).getDownloadURL();

        // Save image data to Firestore
        await imageCollection.doc(imageName).set({
          'url': imageUrl,
          'fileName': imageName,
          'date': DateTime.now(),
          'uploaded_by': 'Coach',
          'category': _categoryController.text,
          'instructions': _instructionTextController.text,
        });
      }

      if (pickedVideoFile != null) {
        final String videoName = path.basename(pickedVideoFile!.path);
        File videoFile = File(pickedVideoFile!.path);

        // Upload the selected video to Firebase Storage
        await storage.ref(videoName).putFile(
              videoFile,
              SettableMetadata(
                customMetadata: {
                  'uploaded_by': 'coach..',
                },
              ),
            );

        final videoUrl = await storage.ref(videoName).getDownloadURL();

        // Save video data to Firestore
        await imageCollection.doc(videoName).set({
          'url': videoUrl,
          'fileName': videoName,
          'date': DateTime.now(),
          'uploaded_by': 'Coach',
          'category': _categoryController.text,
          'instructions': _instructionTextController.text,
        });
      }

      // Refresh the UI
      setState(() {});
    } else if (confirmUpload == false) {
      // User selected "No" in the dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Upload canceled'),
        ),
      );
    } else {
      // User dismissed the dialog without making a selection
      return;
    }
  }

  List<String> listItem = ["Chest", "Abs", "Shoulder", "Triceps"];

  @override
  void initState() {
    super.initState();
    videoController = VideoPlayerController.network('');
  }

  @override
  void dispose() {
    videoController?.dispose();
    super.dispose();
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
              controller: _nameTextController,
              decoration: InputDecoration(
                labelText: "Name",
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
                Column(
                  children: [
                    DropdownButton(
                      hint: const Text("Select Category"),
                      icon: const Icon(Icons.arrow_drop_down),
                      iconSize: 20,
                      isExpanded: false,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                      value: valueChoose,
                      onChanged: (value) {
                        setState(() {
                          valueChoose = value as String?;
                          _categoryController.text = valueChoose ?? '';
                        });
                      },
                      items: listItem.map((valueItem) {
                        return DropdownMenuItem(
                          value: valueItem,
                          child: Text(valueItem),
                        );
                      }).toList(),
                    ),
                  ],
                )
              ],
            ),
            TextFormField(
              controller: _instructionTextController,
              decoration: InputDecoration(
                labelText: "Give the Instruction",
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
                Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await _pickVideo();
                        videoController =
                            VideoPlayerController.file(pickedVideoFile!)
                              ..initialize().then((_) {
                                setState(() {});
                              });
                      },
                      icon: const Icon(Icons.video_library_sharp),
                      label: const Text('Pick Video'),
                    ),
                    // if (videoController != null &&
                    //     videoController!.value.isInitialized)
                    //   AspectRatio(
                    //     aspectRatio: videoController!.value.aspectRatio,
                    //     child: VideoPlayer(videoController!),
                    //   ),
                  ],
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
          ],
        ),
      ),
    );
  }
}
