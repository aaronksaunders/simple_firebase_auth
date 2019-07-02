### New Packages used
*   cloud_firestore: 0.12.5+2 - to save data to firestorm
*   image_picker:  0.6.0+10 - pick an image from the phone gallery or from camera
*   image:  2.1.4 - used to resize the image to create a thumbnail
*   path_provider: 1.1.0 - get device path information for manipulating the image file

### New Widgets Created
* FileUploadButtonBar - a button bar containing a button for selecting the file, uploading the file and one for reseting the currently selected file.
* ImageList - list specific information regarding the images in the list

### Application Flow
1. query images collection in firebase to get documents
2. Pass document to ImageList Widget to render
3. Select an image from the camera or the gallery
4. Create a thumbnail of the image to show user, probably will resize the Image for uploading 
5. Capture additional information to store with image
6. Upload the images using firebase
7. Then create an additional object in the “Image” collection where we store additional information on the Image
8. Reset the application UI


## Things to Check On Android If It Doesn't Work

`gradle.properties`
```
android.useAndroidX=true
android.enableJetifier=true
```

`build.gradle`
```
defaultConfig {
    // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
    applicationId "com.example.simple_firebase_auth"
    minSdkVersion 17
    targetSdkVersion 28
    multiDexEnabled true  <== THIS IS NEW
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName
    testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"
}
```

`pubspec.yaml` - Make Sure Your Versions Are Compatible
```
firebase_core: 0.4.0+6
firebase_auth: 0.11.1+7
cloud_firestore: 0.12.5+2
  ```
