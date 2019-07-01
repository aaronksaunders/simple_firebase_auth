import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth.dart';
import 'components/FileUploadButtonBar.dart';
import 'components/ImageList.dart';

class HomePage extends StatefulWidget {
  final FirebaseUser currentUser;

  HomePage(this.currentUser);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File imageThumb;
  File image;

  uploadTheFile(Function _updateCallback(StorageTaskSnapshot _progress)) async {
    var downloadURL;

    // get current user
    var currentUser = await FirebaseAuth.instance.currentUser();
    var uniqueStr =
        DateTime.now().millisecondsSinceEpoch.toString() + currentUser.uid;

    // convert thumb to base64 string to save with info for faster
    // screen updates
    List<int> imageBytes = await imageThumb.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // upload to storage image to storage
    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('images-' + currentUser.uid)
        .child(uniqueStr);

    final StorageUploadTask uploadTask = ref.putFile(
      image,
      StorageMetadata(
        contentLanguage: 'en',
        //customMetadata: <String, String>{'activity': 'test'},
      ),
    );

    uploadTask.events.listen((_event) async {
      print(_event);
      if (_event.type == StorageTaskEventType.progress) {
        print(
            _event.snapshot.bytesTransferred / _event.snapshot.totalByteCount);
        _updateCallback(_event.snapshot);
      } else if (_event.type == StorageTaskEventType.success) {
        print(_event.snapshot.ref);
        downloadURL = await _event.snapshot.ref.getDownloadURL();

        // upload to image collection
        var result = await Firestore.instance.collection('Images').add({
          'image': downloadURL,
          'thumb': base64Image,
          'owner_id': currentUser.uid,
          'owner': currentUser.email,
          'subject': "test image upload " + uniqueStr
        });
      } else if (_event.type == StorageTaskEventType.failure) {
        print(_event.snapshot.error);
      }
    }, onDone: () async {
      print("onDone");
    }, onError: (_error) {
      print(_error);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Flutter Firebase"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await Provider.of<AuthService>(context).logout();
              })
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
              'Welcome ${widget.currentUser.email}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20.0),
            // Box to hold the thumb of the image, if nothing then
            // show empty container
            imageThumb != null
                ? SizedBox(height: 100.0, child: Image.file(imageThumb))
                : new Container(),
            // button bar to get the image
            FileUploadButtonBar(
              imageFile: imageThumb,
              onUploadFile: () async {
                uploadTheFile((_progress) {
                  print(_progress.bytesTransferred / _progress.totalByteCount);
                });
              },
              onChangeFile: (Map<String, File> _imageInfo) {
                setState(() {
                  imageThumb = _imageInfo['thumb'];
                  image = _imageInfo['file'];
                });
              },
            ),
            SizedBox(height: 20.0),
            Expanded(child: ImageList())
          ],
        ),
      ),
    );
  }
}
