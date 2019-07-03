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
            SizedBox(height: 10.0),
            Text(
              'Welcome ${widget.currentUser.email}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            ImageSelectAndUpload(),
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
      AnimatedContainer(
        height: (imageThumb != null ? 120.0 : 0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: imageThumb != null
              ? SizedBox(height: 100.0, child: Image.file(imageThumb))
              : new Container(),
        ),
        duration: Duration(milliseconds: 300),
      ),
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
