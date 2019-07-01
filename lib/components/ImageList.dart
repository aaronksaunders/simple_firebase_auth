import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

//import 'package:provider/provider.dart';

class ImageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // get the stream of image Items
    var courseDocStream = Firestore.instance.collection('Images').snapshots();

    return StreamBuilder<QuerySnapshot>(
        stream: courseDocStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          // display any errors...
          if (snapshot.hasError) {
            return new Text('Error: ${snapshot.error}');
          }
          // wait for a response from the stream
          else if (snapshot.connectionState == ConnectionState.active) {
            // if no data, display message
            if (snapshot.data.documents.length == 0) {
              return Text('No Items Retrieved');
            }
            // if data the create the list items
            else {
              return ListView(
                  shrinkWrap: false,
                  children:
                      snapshot.data.documents.map((DocumentSnapshot document) {
                    var thumb;
                    if (document['thumb'] != null) {
                      Uint8List thumbBytes = base64Decode(document['thumb']);
                      thumb = SizedBox(
                          width: 100.0,
                          height: 100.0,
                          child: Image.memory(thumbBytes));
                    } else {
                      thumb = SizedBox(
                        width: 100.0,
                        height: 100.0,
                      );
                    }
                    return new ListTile(
                      title: new Text(document['subject']),
                      subtitle: new Text(document['owner']),
                      leading: thumb,
                    );
                  }).toList());
            }
          } else {
            return Text('Loading...');
          }
        });
  }
}

// data model
class ImageItem {
  String subject;
  String owner;
  String id;

  ImageItem({this.subject, this.owner, this.id});
}
