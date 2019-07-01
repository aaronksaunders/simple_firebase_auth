import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as ImagePlugin;
import 'package:path_provider/path_provider.dart';

class FileUploadButtonBar extends StatelessWidget {
  const FileUploadButtonBar({
    Key key,
    @required this.onChangeFile,
    @required this.imageFile, 
    @required this.onUploadFile,
  }) : super(key: key);

  final void Function(Map<String, File> imageInfo) onChangeFile;
  final void Function() onUploadFile;
  final File imageFile;

  @override
  Widget build(BuildContext context) {
    return ButtonBar(mainAxisSize: MainAxisSize.min, children: [
      RaisedButton(
          child: Icon(Icons.camera_alt),
          onPressed: () async {
            // pick the image
            var pickedImage =
                await ImagePicker.pickImage(source: ImageSource.gallery);

            // load file into memory so we can resize it for the thumb
            var image = ImagePlugin.decodeImage(
                File(pickedImage.path).readAsBytesSync());
            // resize into thumb
            var thumbnail = ImagePlugin.copyResize(image, width: 240);

            // create file path to save thumbnail
            var docPath = (await getApplicationDocumentsDirectory()).path;
            var tstamp = DateTime.now().millisecondsSinceEpoch.toString();
            var fileName = '$docPath/thumbnail-test-$tstamp.png';

            // save the thumbnail
            new File(fileName)
              ..writeAsBytesSync(ImagePlugin.encodePng(thumbnail));

            // delete any old thumb...
            if (imageFile != null) await imageFile.delete();

            // return the information to parent
            onChangeFile({
              'thumb': new File(fileName),
              'file': new File(pickedImage.path)
            });
          }),
      RaisedButton(
          child: Icon(Icons.file_upload),
          onPressed: imageFile != null
              ? () async {
                  print("upload file");
                  onUploadFile();
                }
              : null),
      RaisedButton(
          child: Icon(Icons.clear),
          onPressed: imageFile != null
              ? () async {
                  await imageFile.delete();
                  onChangeFile({'thumb': null, 'file': null});
                }
              : null),
    ]);
  }
}
