import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ViewPackage extends StatefulWidget {
  const ViewPackage({Key? key}) : super(key: key);

  @override
  State<ViewPackage> createState() => _ViewPackageState();
}

class _ViewPackageState extends State<ViewPackage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  CollectionReference imageCollection = FirebaseFirestore.instance.collection('packages');
  late String url;

  Future<void> _showConfirmationDialog(String fileName) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white70,
          title: const Text('Confirm Deletion',  style:TextStyle(
              color: Colors.black,
            fontWeight: FontWeight.bold,
          fontSize: 15,
        ),),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Are you sure you want to delete this package?' , style:TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style:TextStyle(
                color: Color(0xff9b1616),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style:TextStyle(
                color: Color(0xff9b1616),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),),
              onPressed: () {
                _delete(fileName);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadMedia() async {
    List<Map<String, dynamic>> mediaFiles = [];

    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('packages').get();

    for (final DocumentSnapshot doc in snapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      mediaFiles.add({
        "url": data['url'] ?? '',
        "fileName": data['fileName'] ?? '',
        "date": data['date'] ?? '',
        "uploaded_by": data['uploaded_by'] ?? 'Nobody',
        "description": data['description'] ?? 'No description',
      });
    }
    return mediaFiles;
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref().child('package/${ref}').delete();
    await imageCollection.doc(ref).delete();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder(
                future: _loadMedia(),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> media =
                            snapshot.data![index];

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            children: [
                              ListTile(
                                dense: false,
                                title: Text(media['fileName']),
                                subtitle: Column(

                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [

                                    SizedBox(height: 10),
                                    Text('Description: ${media['description']}'),
                                    SizedBox(height: 10),
                                    Text('date: ${media['date']} '),
                                    SizedBox(height: 10),
                                    Text('uploaded_by: ${media['uploaded_by']} '),
                                  ],
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    if (media != null && media.containsKey('fileName')) {
                                      _showConfirmationDialog(media['fileName']);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
