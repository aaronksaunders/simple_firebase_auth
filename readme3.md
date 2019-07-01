New Packages used
*   cloud_firestore: 0.11.0+2 - to save data to firestorm
*   image_picker:  0.6.0+10 - pick an image from the phone gallery or from camera
*   image:  2.1.4 - used to resize the image to create a thumbnail
*   path_provider: 1.1.0 - get device path information for manipulating the image file

New Widgets Created
* FileUploadButtonBar - a button bar containing a button for selecting the file, uploading the file and one for reseting the currently selected file.
* ImageList - list specific information regarding the images in the list

Application Flow
1. query images collection in firebase to get documents
2. Pass document to ImageList Widget to render
3. Select an image from the camera or the gallery
4. Create a thumbnail of the image to show user, probably will resize the Image for uploading 
5. Capture additional information to store with image
6. Upload the images using firebase
7. Then create an additional object in the “Image” collection where we store additional information on the Image
8. Reset the application UI
