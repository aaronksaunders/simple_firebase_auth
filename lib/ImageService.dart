import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/cupertino.dart';

 

class ImageService with ChangeNotifier {
 
  uploadTheFile(Map<String,File> _imageInfo, Function _updateCallback(StorageTaskSnapshot _progress)) async {
    var downloadURL;

    // get current user
    var currentUser = await FirebaseAuth.instance.currentUser();
    var uniqueStr =
        DateTime.now().millisecondsSinceEpoch.toString() + currentUser.uid;

    // convert thumb to base64 string to save with info for faster
    // screen updates
    List<int> imageBytes = await _imageInfo['imageThumb'].readAsBytes();
    String base64Image = base64Encode(imageBytes);

    // upload to storage image to storage
    final StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('images-' + currentUser.uid)
        .child(uniqueStr);

    final StorageUploadTask uploadTask = ref.putFile(
      _imageInfo['image'],
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
}
