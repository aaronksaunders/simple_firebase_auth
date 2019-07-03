import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ImageService.dart';
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
            ImageSelectAndUpload(),
            SizedBox(height: 20.0),
            Expanded(child: ImageList())
          ],
        ),
      ),
    );
  }
}

class ImageSelectAndUpload extends StatefulWidget {
  const ImageSelectAndUpload({
    Key key,
  }) : super(key: key);

  @override
  _ImageSelectAndUploadState createState() => _ImageSelectAndUploadState();
}

class _ImageSelectAndUploadState extends State<ImageSelectAndUpload> {
  File imageThumb;
  File image;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Box to hold the thumb of the image, if nothing then
      // show empty container
      imageThumb != null
          ? SizedBox(height: 100.0, child: Image.file(imageThumb))
          : new Container(),
      // button bar to get the image
      FileUploadButtonBar(
        imageFile: imageThumb,
        onUploadFile: () async {
          ImageService().uploadTheFile({
            'imageThumb': imageThumb,
            'image': image
          }, // information for file upload
              (_progress) {
            print(_progress.bytesTransferred / _progress.totalByteCount);
          });
        },
        onChangeFile: (Map<String, File> _imageInfo) {
          setState(() {
            imageThumb = _imageInfo['thumb'];
            image = _imageInfo['file'];
          });
        },
      )
    ]);
  }
}
