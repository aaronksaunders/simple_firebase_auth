# Simple Firebase Login Flow in Flutter - Part Two

In part one we created a simple application with the following components
- Default Main App Entry Point
  - Use of [FutureBuilder Widget](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html
  ) to wait for data before rendering UI, a concept used throughout the app
- Login Page
- Home Page
- Authentication Service 
  - Demonstrate the use of the Provider as discussed here in the Flutter Documentation [Simple App State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple#accessing-the-state)

Now in part two we will integrate firebase into the application.

>There are plenty of examples online about setting up Firebase for Flutter so I will jump right into the code instead of walking thru the basics. 
>See [Google CodeLabs Flutter for Firebase](https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html?index=..%2F..index#5) for step by step instructions for setting up you project on iOS or Android

### Create a Test User in Firebase
Since we are just building the application and there is no functionality to create users in the application right now, please login to your [Firebase Console]([https://console.firebase.google.com/u/0/](https://console.firebase.google.com/u/0/)) and add a user to your project. Please be sure to enable email authentication when updating the project in your Firebase Console.

### Steps For Adding Firebase Functionality to the Project
- Add the Firebase methods to the `AuthService`
- Access the `getUser` property from the `AuthService` at startup to determine which page to load in `main.dart`
- Modify `HomePage` to show email address of the logged in `FirebaseUser`
- Modify `LoginPage` to call the `loginUser` method on the `AuthService` to login a user using the Firebase API to see if we can login a real  `FirebaseUser`
- Finally handle the errors appropriately when logging in and when looking for a current user at startup

#### Authentication Service: Adding Firebase API Functionality
First the authentication service which is where we are just wrapping some of the basic firebase functions that we need for authentication and determining if there is already a user persisted from a previous session
```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';

class AuthService with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ///
  /// return the Future with firebase user object FirebaseUser if one exists
  ///
  Future<FirebaseUser> getUser() {
    return _auth.currentUser();
  }

  // wrapping the firebase calls
  Future logout() async {
    var result = FirebaseAuth.instance.signOut();
    notifyListeners();
    return result;
  }
  
  ///
  /// wrapping the firebase call to signInWithEmailAndPassword
  /// `email` String
  /// `password` String
  ///
  Future<FirebaseUser> loginUser({String email, String password}) async {
    try {
      var result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      // since something changed, let's notify the listeners...
      notifyListeners();
      return result;
    }  catch (e) {
      // throw the Firebase AuthException that we caught
      throw new AuthException(e.code, e.message);
    }
  }
}

```
As you can see from the code above, we still have the same methods for accessing our `AuthService` the only difference now is that we have replaces the call with real calls to the Firebase backend that you have set up.

Notice we no longer need to keep a property with the current user since Firebase will manage that for us. All we need to do is call the method `getUser` and if there is a user we will get an object, otherwise it will return null.

Most important to notice is that we are calling `notifyListeners()` when the login state is changing during logging in or logging out.

#### Modifying `main.dart`
There are no real modifications needed to the file since we are working with the same external API, the only difference is that now we are returning a `FirebaseUser` object so let's add a specific type to the code, and touch up a few more things
```dart
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<FirebaseUser>(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) { //          ⇐ NEW
          if (snapshot.connectionState == ConnectionState.done) {
            // log error to console                                            ⇐ NEW
            if (snapshot.error != null) {
              print("error");
              return Text(snapshot.error.toString());
            }
            // redirect to the proper page, pass the user into the 
            // `HomePage` so we can display the user email in welcome msg     ⇐ NEW
            return snapshot.hasData ? HomePage(snapshot.data) : LoginPage();
          } else {
            // show loading indicator                                         ⇐ NEW
            return LoadingCircle();
          }
        },
      ),
    );
  }
}
```
We have added the object type, `FirebaseUser`, associated with the `AsyncSnapshot` and we are now checking for an error in case there is a problem loading Firebase initially.

We have also added a new parameter to the constructor of the `HomePage` widget which is the `FirebaseUser` object returned from `getUser` call made to the `AuthService`. We will a see in the next section how the new parameter is used.

Finally we added a new widget called `LoadingCircle` to give us a nice user experience when the application is starting up and accessing `Firebase` to check for a new user; See the code below for the `LoadingCircle` widget.
> See documentation on [`CircularProgressIndicator` ]([https://api.flutter.dev/flutter/material/CircularProgressIndicator/CircularProgressIndicator.html](https://api.flutter.dev/flutter/material/CircularProgressIndicator/CircularProgressIndicator.html))
```dart
class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: CircularProgressIndicator(),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}
```
#### Modifying HomePage Widget in  `home_page.dart`
We need to first modify the widget by adding a new constructor that will hold the firebase user passed in from the FutureBuilder in `main.dart`
```dart
class HomePage extends StatefulWidget {
  final FirebaseUser currentUser;    // ⇐ NEW

  HomePage(this.currentUser);        // ⇐ NEW

  @override
  _HomePageState createState() => _HomePageState();
}
```
Now we have access to the information on the current user from the widget; we can access it when rendering the `HomePage` by make the modifications you see below. We will just add a few more widgets to the build method:
```dart
     children: <Widget>[
       SizedBox(height: 20.0),                         // ⇐ NEW
       Text(                                           // ⇐ NEW
         'Home Page Flutter Firebase  Content',
         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
       ),
       SizedBox(height: 20.0),                         // ⇐ NEW
       Text(                                           // ⇐ NEW
          `Welcome ${widget.currentUser.email}`,
           style: TextStyle(    
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
       SizedBox(height: 20.0),
       RaisedButton(
           child: Text("LOGOUT"),
           onPressed: () async {
             await Provider.of<AuthService>(context).logout();
           })
     ],
```
#### Modifying LoginPage Widget in  `login_page.dart`
Since the API signature hasn't changed we need to do very little to this function to get the desired results, however it would be best to do some better error checking.

With `Future` we need to wrap the call with a `try` `catch` block since any errors that happen with Firebase will be thrown as exceptions. We then will display the error message in a dialog, see code for the method `_buildErrorDialog` and the rest of the changes below.

Add the new import for the error exception
```dart
import  'package:firebase_auth/firebase_auth.dart';
```
Make the appropriate changes to the `onPressed` method of the login button.
```dart
     onPressed: () async {
       // save the fields..
       final form = _formKey.currentState;
       form.save();

       // Validate will return true if is valid, or false if invalid.
       if (form.validate()) {
         try {
           FirebaseUser result =
               await Provider.of<AuthService>(context).loginUser(
                   email: _email, password: _password);
           print(result);  
         } on AuthException catch (error) {
           // handle the firebase specific error
           return _buildErrorDialog(context, error.message);
         } on Exception catch (error) {
           // gracefully handle anything else that might happen..        
           return _buildErrorDialog(context, error.toString());
         }
       }
     },
```
Add the code for the new private `_buildErrorDialog` method that will display errors from the call to the `AuthService` login method.
```dart 
  Future _buildErrorDialog(BuildContext context, _message) {
    return showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('Error Message'),
          content: Text(_message),
          actions: <Widget>[
            FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                })
          ],
        );
      },
      context: context,
    );
  }
```