# Simple Firebase Login Flow in Flutter

We will create a simple application with the following components
- Default Main App Entry Point
  - Use of [FutureBuilder Widget](https://api.flutter.dev/flutter/widgets/FutureBuilder-class.html
  ) to wait for data before rendering UI, concept used throughout the app
- Login Page
- Home Page
- Authentication Service 
  - Demonstrate the use of the Provider as discussed here in the Flutter Documentation [Simple App State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt/simple#accessing-the-state)

There are plenty of examples online about setting up Firebase for Flutter so I will jump right into the code instead of walking thru the basics. 

>See [Google CodeLabs Flutter for Firebase](https://codelabs.developers.google.com/codelabs/flutter-firebase/index.html?index=..%2F..index#5) for step by step instructions for setting up you project on iOS or Android


### Create a Test User in Firebase
Since we are just building the application and there is no functionalty to create users in the application right now, please login to you Firebase Console and add an user to your project. Please be sure to enable email authentication when updating the project in your Firebase Console.


### Cleaning Up the Default Flutter Project
first lets create the project
```
flutter create simple_firebase_auth
```
Now lets do some project cleanup, open up the project and delete the existing `HomePage` and `HomePageState` widget from the file `main.dart`.

Change the `home` property of the `MaterialApp` widget to point to the `LoginPage` widget we are about to create in the next section

The file should look similar to this when completed
```javascript
import 'package:flutter/material.dart';
import 'package:simple_firebase_auth/login_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
```


### Create the LoginPage Widget
Lets walk through the creation of the `LoginPage` for the application. We need capture an `email` and a `password` to pass to the `AuthService` to call the login function.

We are going to create a simple page with the required `TextFormField` widgets and one `RaisedButton` to click to make the login happen.

1. Open your editor and create a new file in the `lib` directory named `login_page.dart`
1. Paste the contents below into the file `login_page.dart`
```javascript
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Page Flutter Firebase"),
      ),
      body: Center(
        child: Text('Login Page Flutter Firebase  Content'),
      ),
    );
  }
}

```
you should be able to run the code to see what the screen looks like now. Be sure to change the default route or `home` property in `main.dart` widget to `LoginPage` while we work through the UI so you can see the changes with live reload

#### Style and Adding Text Fields

Lets make the body of the page a centered `Column` with the childre of the column being primarily the `TextFormField`s and the `RaisedButton`

the centered container to hold the form fields and buttons
```javascript
    body: Container(
      padding: EdgeInsets.all(20.0),
      child: Column()
    )
```
Next add the actual form field widgets and the buttons as children of the `Column` widget. We will do some basic styling of the form fields so that this looks presentable. See the Flutter documentation for more information on [TextFormFields](https://api.flutter.dev/flutter/material/TextFormField-class.html)
```javascript
  body: Container(
    padding: EdgeInsets.all(20.0),
    child: Column(
      children: <Widget>[
        Text(
          'Login Information',
          style: TextStyle(fontSize: 20),
        ),
        TextFormField(
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(labelText: "Email Address")),
        TextFormField(
            obscureText: true,
            decoration: InputDecoration(labelText: "Password")),
        RaisedButton(child: Text("LOGIN"), onPressed: () {}),
      ],
    ),
  ),
```
Lets add some spacing between the fields in the column so it is more presentable. We are going to use the `SizedBox` widget and set the `height` property to get some spacing in the application. Replace the `children` property of the `Column` widget to get the desired spacing
```javascript
  children: <Widget>[
    SizedBox(height: 20.0),    // <= NEW
    Text(
      'Login Information',
      style: TextStyle(fontSize: 20),
    ),
    SizedBox(height: 20.0),   // <= NEW
    TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(labelText: "Email Address")),
    TextFormField(
        obscureText: true,
        decoration: InputDecoration(labelText: "Password")),
    SizedBox(height: 20.0),  // <= NEW
    RaisedButton(child: Text("LOGIN"), onPressed: () {}),
  ],
```
#### Getting Text Values from Form Fields
We are going to be using a `Form` widget and a `GlobalKey`, additional information on these concepts can be found in the flutter cookbook section [Building a form with validation](https://flutter.dev/docs/cookbook/forms/validation)

Add the formKey in the `LoginPage` widget
```javascript
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
```
Then add two new fields to hold the email address and password values we will need to send to Firebase for authentication
```javascript
class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;
```
Next we add a property `onSaved` to the `TextFormFields` we have for email and password, when the `save` method is called on the form, all of the widgets onSaved methods will be called to update the local variables.
```javascript
  TextFormField(
      onSaved: (value) => _email = value,    // <= NEW
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(labelText: "Email Address")),
  TextFormField(
      onSaved: (value) => _password = value, // <= NEW
      obscureText: true,
      decoration: InputDecoration(labelText: "Password")),
```
Wrap the `Column` Widget with a new `Form` Widget, the code should look similar to this
```javascript
      body: Container(
        padding: EdgeInsets.all(20.0),
        child: Form(          // <= NEW
          key: _formKey,      // <= NEW
          child: Column(
            children: <Widget>[
            ....
            ],
          ),
        ),
      ),            
```
Now that the fields are set, the `TextFormField` are updated, we can using the `_formKey` to not only validate the fields provided, but to also get the values locally by calling the `save` method.

Replace the code in the `RaisedButton` `onPressed` method to the following, and you will see that we are getting the values for email and password set in out widget. We can now pass these values to the `AuthService` that wraps the Firebase signin functionality.

```javascript
    // save the fields..
    final form = _formKey.currentState;
    form.save();

    // Validate will return true if is valid, or false if invalid.
    if (form.validate()) {
      print("$_email $_password");
    }
```


### Create the HomePage Widget
For now, we will keep the home page simple since we are just trying to demonstrate how the flow works. Ignore the commented out `LogoutButton` widget, we will discuss that in a later section of the tutorial.

1. Open your editor and create a new file in the `lib` directory named `home_page.dart`
1. Paste the contents below into the file `home_page.dart`

```javascript
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text("Home Flutter Firebase"),
        //actions: <Widget>[LogoutButton()],
      ),
      body: Center(
        child: Text('Home Page Flutter Firebase  Content'),
      ),
    );
  }
}
```
3. Open `main.dart` and add the following import statement
```javascript
import 'home_page.dart';
```
4. Change the `home` property from this:
```javascript
home: HomePage(title: 'Flutter Demo Home Page'),
```
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;to this so you can verify that the page is working properly
```javascript
home: HomePage(),
```
### Creating a Template for An Authentication Service
Here we will build out the authentication service seperate from Firebase, validate that everything works and then integrate Firebase.

What we need as a baseline is the following:
```javascript
import 'dart:async';

class AuthService {
  var currentUser;

  AuthService() {
    print("new AuthService");
  }

  // gets the current user if there is one
  Future getUser() {
    return Future.value(currentUser);
  }

  // clears the current user
  Future logout() {
    this.currentUser =  null;
    return Future.value(currentUser);
  }

  // logs in the user if password matches
  Future loginUser({String email, String password}) {
    if ( password == 'password123') {
       this.currentUser =  {'email': email};
       return Future.value(currentUser);
    } else {
        this.currentUser = null;
       return Future.value(null);
    }
  }
}

```
We will keep a local property in the service of the `currentUser` object, when the user calls the `login` method, if the password matches we will set current user and the user will be logged in. This will now provide a user when the call is made to `getUser` method. For logging the user out, we will set the `currentUser`property to null.


### Determining a User On Application Launch
The first challange when working with the application is to determine which page to open when the application starts up. What we want to do here is determine if we have a user or not. We will be using an `AuthService` we will create later combined with the `FutureBuilder` widget from flutter to render the correct first page of either a `HomePage` or a `LoginPage`

Go into the `main.dart` file in your project and make the following changes to the main widget of your application. Replace the `home` property on

```javascript
home: FutureBuilder<dynamic>(
    // using the function from the service to get a user id there
    // is one.
    future: AuthService().getUser,

    // we will build the next widget based on if there is a user
    // of not returned from the call to the AuthService
    builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
        // when the Future is completed, check to see if we got data
        if (snapshot.connectionState == ConnectionState.done) {
           final bool loggedIn = snapshot.hasData;

           // if we got data, then render the HomePage, otherwise
           // render the login page
           return loggedIn ? HomePage() : LoginPage();
        } else {
           // if we are not done yet with the Future, load a spinner
           return LoadingCircle();
        }
    }),
```

### Authentication Service Wrapping Firebase Functionality

First the authentication service which is where we are just wrapping some of the basic firebase functions that we need for authentication and determining if there is already a user persisted from a previous session

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // return the Future with firebase user if one exists
  Future<FirebaseUser> get getUser => _auth.currentUser();

  // wrapping the firebase calls
  Future logout() {
    return FirebaseAuth.instance.signOut();
  }

  // wrapping the firebase calls
  Future createUser(
      {String firstName,
      String lastName,
      String email,
      String password}) async {
    var u = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    UserUpdateInfo info = UserUpdateInfo();
    info.displayName = '$firstName $lastName';
    return await u.updateProfile(info);
  }

  // wrapping the firebase calls
  Future<FirebaseUser> loginUser({String email, String password}) {
    return FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }
}

```
