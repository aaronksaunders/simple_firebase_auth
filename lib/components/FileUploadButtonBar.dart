import 'dart:io';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as ImagePlugin;
// import 'package:path_provider/path_provider.dart';
import 'package:simple_firebase_auth/ImageService.dart';

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
            if (pickedImage == null) return;

            final thumbFile =
                await ImageService().createThumbFileFromImageFile(pickedImage);

            // delete any old thumb...
            if (imageFile != null) await imageFile.delete();

            // return the information to parent
            onChangeFile({'thumb': thumbFile, 'file': File(pickedImage.path)});
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
