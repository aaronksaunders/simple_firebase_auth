import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'auth.dart';
import 'login_page.dart';

void main() => runApp(
      ChangeNotifierProvider<AuthService>(
        child: MyApp(),
        builder: (BuildContext context) {
          return AuthService();
        },
      ),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder<FirebaseUser>(
        future: Provider.of<AuthService>(context).getUser(),
        builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // log error to console
            if (snapshot.error != null) {
              print("error");
              return Text(snapshot.error.toString());
            }

            // redirect to the proper page
            return snapshot.hasData
                ? HomePage(currentUser: snapshot.data)
                : LoginPage();
          } else {
            // show loading indicator
            return LoadingCircle();
          }
        },
      ),
    );
  }
}

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
