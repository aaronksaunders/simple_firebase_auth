import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:simple_firebase_auth/ImageService.dart';

class ImageList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // get the stream of image Items
    var courseDocStream = ImageService().imageDataStream;

    return StreamBuilder<QuerySnapshot>(
        stream: courseDocStream,
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
                    var thumb = ImageService().makeThumbFromDoc(document);

                    return new ListTile(
                      key: Key(document['uid']),
                      title: new Text(document['subject']),
                      subtitle: new Text(document['owner']),
                      leading: thumb,
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

// data model
class ImageItem {
  String subject;
  String owner;
  String id;

  ImageItem({this.subject, this.owner, this.id});
}
