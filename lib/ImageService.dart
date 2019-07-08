import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as ImagePlugin;
import 'package:path_provider/path_provider.dart';

class ImageService with ChangeNotifier {
  Stream<QuerySnapshot> get imageDataStream {
    return Firestore.instance.collection('Images').snapshots();
  }

  Future<File> createThumbFileFromImageFile(
    File _imageFile,
  ) async {
    // load file into memory so we can resize it for the thumb
    var image =
        ImagePlugin.decodeImage(File(_imageFile.path).readAsBytesSync());
    // resize into thumb
    var thumbnail = ImagePlugin.copyResize(image, width: 240);

    // create file path to save thumbnail
    var docPath = (await getApplicationDocumentsDirectory()).path;
    var tstamp = DateTime.now().millisecondsSinceEpoch.toString();
    var fileName = '$docPath/thumbnail-test-$tstamp.png';

    // save the thumbnail
    var f = new File(fileName);

    f.writeAsBytesSync(ImagePlugin.encodePng(thumbnail));
    return Future.value(f);
  }

  ///
  /// [ _imageInfo ] this is a map containing two file objects the file
  ///  to upload and the thumbnail version of the file which can be
  /// used for rendering in a list
  ///
  /// [ _progress ] is a function call back that return the `StorageTaskSnapshot`
  /// object from the Firebase task; this can be used for providing and
  /// update on the upload process
  ///
  Future<dynamic> uploadTheFile(Map<String, File> _imageInfo,
      Function _updateCallback(StorageTaskSnapshot _progress)) async {
    var downloadURL;
    var value;

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
        value = await Firestore.instance.collection('Images').add({
          'image': downloadURL,
          'thumb': base64Image,
          'owner_id': currentUser.uid,
          'owner': currentUser.email,
          'subject': "test image upload " + uniqueStr
        });
      } else if (_event.type == StorageTaskEventType.failure) {
        print(_event.snapshot.error);
      }
    });

    return await uploadTask.onComplete;
  }

  makeThumbFromDoc(DocumentSnapshot document) {
    if (document['thumb'] != null) {
      Uint8List thumbBytes = base64Decode(document['thumb']);
      return SizedBox(
          width: 100.0, height: 100.0, child: Image.memory(thumbBytes));
    } else {
      return SizedBox(
        width: 100.0,
        height: 100.0,
      );
    }
  }
}
