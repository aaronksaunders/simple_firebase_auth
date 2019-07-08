import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:simple_firebase_auth/ImageService.dart';

class ImageList extends StatefulWidget {
  const ImageList({
    Key key,
    @required this.onItemClick,
    @required this.listStream,
  }) : super(key: key);

  final void Function(String, String) onItemClick;
  final Stream listStream;

  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  @override
  Widget build(BuildContext context) {
    print("build - ImageList");

    return StreamBuilder<QuerySnapshot>(
        stream: widget.listStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print(snapshot.connectionState);

          // display any errors...
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          // wait for a response from the stream
          if (snapshot.hasData) {
            print(snapshot.connectionState);
            print(snapshot.hasData);
            final documents = snapshot.data.documents;
            // if no data, display message
            if (documents.length == 0) {
              return Text('No Items Retrieved');
            }
            // if data the create the list items
            else {
              return ListView(
                  shrinkWrap: false,
                  children: documents.map((DocumentSnapshot document) {
                    return new ImageListItem(
                      document: document,
                      widget: widget,
                    );
                  }).toList());
            }
          }

          if (snapshot.connectionState != ConnectionState.done) {
            return Align(
              widthFactor: 200.0,
              alignment: Alignment.topCenter,
              child: Container(
                  width: 60.0,
                  height: 60.0,
                  child: CircularProgressIndicator()),
            );
          }
        });
  }
}

class ImageListItem extends StatelessWidget {
  const ImageListItem({
    Key key,
    @required this.document,
    @required this.widget,
  }) : super(key: key);

  final document;
  final ImageList widget;

  @override
  Widget build(BuildContext context) {
    final thumb = ImageService().makeThumbFromDoc(document);
    final heroTag = 'imageHero-${document.documentID}';

    return new ListTile(
      key: Key(document.documentID),
      title: new Text(document['subject']),
      subtitle: new Text(document['owner']),
      leading: Hero(tag: heroTag, child: thumb),
      onTap: () {
        widget.onItemClick(document['image'], heroTag);
      },
    );
  }
}

// data model
class ImageItem {
  String subject;
  String owner;
  String id;

  ImageItem({this.subject, this.owner, this.id});
}
