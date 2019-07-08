import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ImageService.dart';
import 'auth.dart';
import 'components/FileUploadButtonBar.dart';
import 'components/ImageList.dart';

class HomePage extends StatefulWidget {
  final FirebaseUser currentUser;
  Stream<QuerySnapshot> courseDocStream;

  HomePage({
    Key key,
    @required this.currentUser,
  }) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  @override
  void initState() {
    super.initState();
    widget.courseDocStream = ImageService().imageDataStream;
    print("initState - home_page");
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
            SizedBox(height: 10.0),
            Text(
              'Welcome ${widget.currentUser.email}',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic),
            ),
            ImageSelectAndUpload(),
            Expanded(
                child: ImageList(
                    listStream: widget.courseDocStream,
                    onItemClick: (_item, _tag) {
                      print(_item);
                      Navigator.push(context, MaterialPageRoute(builder: (_) {
                        return DetailScreen(_item, _tag);
                      }));
                    }))
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
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
          final v = await ImageService().uploadTheFile({
            'imageThumb': imageThumb,
            'image': image
          }, // information for file upload
              (_progress) {
            print(_progress.bytesTransferred / _progress.totalByteCount);
          });

          print(v);

          // clear UI
          setState(() {
            imageThumb = null;
            image = null;
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

class DetailScreen extends StatelessWidget {
  final String item;
  final String tag;

  DetailScreen(this.item, this.tag);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: FutureBuilder(
              future: precacheImage(NetworkImage(this.item), context),
              builder: (context, snapshot) {
                return Hero(
                  tag: this.tag,
                  child: Image.network(
                    this.item,
                  ),
                );
              }),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
