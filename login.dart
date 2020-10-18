import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:frontend/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/util/serverDetails.dart';
import 'package:frontend/util/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'crediantial.dart';

import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // final loginau;
  // _LoginPageState(this.loginau);
  bool isSameEmail = true;
  bool _isLoading = false;
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();
  final TextEditingController resetemailController =
      new TextEditingController();
  final TextEditingController resetPasswordEmailPasswordController =
      new TextEditingController();
  final TextEditingController oldPasswordController =
      new TextEditingController();
  final TextEditingController newPasswordController =
      new TextEditingController();

  FirebaseAuth firebaseAuthen = FirebaseAuth.instance;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light
        .copyWith(statusBarColor: Colors.transparent));
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [Colors.white, Color.fromARGB(255, 20, 54, 91)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
        ),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: <Widget>[
                  headerSection(),
                  textSection(),
                  buttonSection(),
                ],
              ),
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  sendMail(String email) async {
    String username = EMAIL;
    String password = PASS;

    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username)
      ..recipients.add('$email') //recipent email
      ..subject =
          'Password recover link from MMS : ${DateTime.now()}' //subject of the email
      //..text =
      //'This is the plain text.\nThis is line 2 of the text part.'
      ..html = "<h3>Thanks for with localhost."; //body of the email

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' +
          sendReport.toString()); //print if the email is sent
    } on MailerException catch (e) {
      print('Message not sent. \n' +
          e.toString()); //print if the email is not sent
      // e.toString() will show why the email is not sending
    }
  }

  signIn(String email, pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = ServerDetails.ip +
        ':' +
        ServerDetails.port +
        ServerDetails.api +
        'login';
    Map<String, String> headers = {"Content-type": "application/json"};
    var data = jsonEncode({
      'email': email,
      'password': pass,
      'token': FirebaseNotifications.fcmtoken
    });
    var jsonResponse = null;
    var response = await http.post(url, headers: headers, body: data);

    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        setState(() {
          _isLoading = false;
        });
        sharedPreferences.setString("token", jsonResponse['token']);
        sharedPreferences.setString(
            "token_expire_date", jsonResponse['token_expire_date']);
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => MainPage()),
            (Route<dynamic> route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      Widget okButton = FlatButton(
          child: Text("OK"),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => MainPage()));
          });
      setState(() {
        AlertDialog alert = AlertDialog(
          title: Text("Error message"),
          content: Text("Oops! The password is wrong or the email is invalid."),
          actions: [
            okButton,
          ],
        );
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return alert;
          },
        );
      });
      print(response.headers);
      print(response.body);
    }
  }

  changePassword(String email, String pass, String new_pass) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String url = ServerDetails.ip +
        ':' +
        ServerDetails.port +
        ServerDetails.api +
        'user/password';
    Map<String, String> headers = {"Content-type": "application/json"};
    var data = jsonEncode(
        {'email': email, 'password': pass, 'new_password': new_pass});
    print(url);
    var jsonResponse = null;
    var response = await http.put(url, headers: headers, body: data);
    print(response.statusCode);
    if (response.statusCode == 200) {
      jsonResponse = json.decode(response.body);
      if (jsonResponse != null) {
        Widget okButton = FlatButton(
            child: Text("OK"),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MainPage()));
            });
        setState(() {
          AlertDialog alert = AlertDialog(
            title: Text("Notification"),
            content: Text("Password changed successfully"),
            actions: [
              okButton,
            ],
          );
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return alert;
            },
          );
        });
        resetPasswordEmailPasswordController.clear();
        oldPasswordController.clear();
        newPasswordController.clear();
      }
    } else {
      setState(() {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: Text("Error message"),
                  content: Text(
                      "Oops! The password is wrong or the email is invalid."),
                  actions: <Widget>[
                    FlatButton(
                        child: Text('Ok'),
                        onPressed: () => Navigator.of(context)
                            .pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        MainPage()),
                                (Route<dynamic> route) => false)),
                  ],
                ));
      });
      print(response.headers);
      print(response.body);
    }
  }

  Column buttonSection() {
    return Column(children: <Widget>[
      Container(
        width: MediaQuery.of(context).size.width,
        height: 40.0,
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        margin: EdgeInsets.only(top: 15.0),
        child: RaisedButton(
          onPressed: emailController.text == "" || passwordController.text == ""
              ? null
              : () {
                  setState(() {
                    _isLoading = true;
                  });
                  signIn(emailController.text, passwordController.text);
                },
          elevation: 0.0,
          color: Color.fromARGB(255, 135, 193, 218),
          child: Text("LOGIN",
              style: TextStyle(color: Colors.white70, fontSize: 17)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),
      //Register user button
      Container(
        width: MediaQuery.of(context).size.width,
        height: 40.0,
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        margin: EdgeInsets.only(top: 15.0),
        child: RaisedButton(
          onPressed: () {
            Navigator.of(context).pushNamed("/register");
          },
          elevation: 0.0,
          color: Color.fromARGB(255, 135, 193, 218),
          child: Text("REGISTER",
              style: TextStyle(color: Colors.white70, fontSize: 17)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        ),
      ),

      Center(
        child: Container(
            margin: EdgeInsets.only(top: 10.0),
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Center(
              child: Wrap(
                children: <Widget>[
                  Text('Forget your ',
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  new InkWell(
                    onTap: () {
                      createAlertDialog1(context);
                    },
                    child: new Text('Username ',
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                  ),
                  Text('or',
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  new InkWell(
                    onTap: () {
                      createAlertDialog3(context);
                    },
                    child: new Text(' Password ',
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                  ),
                ],
              ),
            )),
      ),

      Center(
        child: Container(
            margin: EdgeInsets.only(top: 10.0),
            padding: EdgeInsets.symmetric(horizontal: 30.0),
            child: Center(
              child: Wrap(
                children: <Widget>[
                  Text('Change ',
                      style: TextStyle(color: Colors.black, fontSize: 15)),
                  new InkWell(
                    onTap: () {
                      createAlertDialog2(context);
                    },
                    child: new Text('Password ',
                        style: TextStyle(color: Colors.white70, fontSize: 15)),
                  ),
                  // Text('?',
                  //     style: TextStyle(color: Colors.black, fontSize: 15)),
                ],
              ),
            )),
      )
    ]);
  }

  Container textSection() {
    return Container(
      padding:
          EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0, bottom: 10.0),
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: emailController,
            cursorColor: Colors.black,
            style: TextStyle(color: Colors.black, fontSize: 17),
            decoration: InputDecoration(
              //icon: Icon(Icons.email, color: Colors.white70),
              hintText: "Email",
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: const BorderRadius.all(
                  const Radius.circular(13.0),
                ),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.only(left: 20.0),
              filled: true,
              fillColor: const Color(0xFFddeff9),
            ),
          ),
          SizedBox(height: 20.0),
          TextFormField(
            controller: passwordController,
            cursorColor: Colors.black,
            obscureText: true,
            style: TextStyle(color: Colors.black, fontSize: 17),
            decoration: InputDecoration(
              //icon: Icon(Icons.lock, color: Colors.white70),
              hintText: "Password",
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: const BorderRadius.all(
                  const Radius.circular(13.0),
                ),
              ),
              hintStyle: TextStyle(color: Colors.grey),
              contentPadding: const EdgeInsets.only(left: 20.0),
              filled: true,
              fillColor: const Color(0xFFddeff9),
            ),
          ),
        ],
      ),
    );
  }

  Container headerSection() {
    return Container(
        margin: EdgeInsets.only(top: 120.0),
        padding: EdgeInsets.only(left: 40.0, right: 20.0),
        child: Container(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Expanded(
                  child: Text(
                "My Medical Secretary ",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: "Arial",
                    color: Colors.blueGrey,
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              )),
              Image.asset('assets/images/logo.png', scale: 2.5),
              //Image.file('../../assets/images/logo.jpg'),
            ])));
  }

  createAlertDialog1(BuildContext context) {
    return showDialog<void>(
      context: context,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Center(
            child: Text('Forget username?',
                style: TextStyle(color: Colors.grey, fontSize: 17)),
          ),
          content: Container(
              height: 40.0,
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: <Widget>[
                  Text('Please contact your clinic'),
                  Text('Ph: 0415181703'),
                ],
              )),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Dismiss alert dialog
              },
            ),
            FlatButton(
              child: Text('Call'),
              onPressed: () => launch("tel://0415181703"),
            ),
          ],
        );
      },
    );
  }

  createAlertDialog2(BuildContext context) {
    return showDialog<void>(
      context: context,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Center(
            child: Text('Change password?',
                style: TextStyle(color: Colors.grey, fontSize: 17)),
          ),
          content: SingleChildScrollView(
              //height: 180.0,
              //padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: new Column(
            children: <Widget>[
//                Text('Please enter your email and'),
//                Text('password to reset.'),
              Wrap(
                children: <Widget>[
                  Center(child: Text('Please enter your email and')),
                  Center(child: Text('password to reset.'))
                ],
              ),
              Container(
                height: 30.0,
                margin: EdgeInsets.only(top: 10.0, bottom: 0.0),
                padding: EdgeInsets.only(left: 0.0),
                child: TextFormField(
                  controller: resetPasswordEmailPasswordController,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  decoration: InputDecoration(
                    //icon: Icon(Icons.email, color: Colors.white70),
                    hintText: "Email...",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(5.0),
                      ),
                    ),
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.only(left: 20.0),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
              ),
              Container(
                height: 30.0,
                margin: EdgeInsets.only(top: 10.0, bottom: 0.0),
                padding: EdgeInsets.only(left: 0.0),
                child: TextFormField(
                  controller: oldPasswordController,
                  cursorColor: Colors.black,
                  obscureText: true,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  decoration: InputDecoration(
                    //icon: Icon(Icons.email, color: Colors.white70),
                    hintText: "Old password...",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(5.0),
                      ),
                    ),
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.only(left: 20.0),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
              ),
              Container(
                height: 30.0,
                margin: EdgeInsets.only(top: 10.0, bottom: 0.0),
                padding: EdgeInsets.only(left: 0.0),
                child: TextFormField(
                  controller: newPasswordController,
                  cursorColor: Colors.black,
                  obscureText: true,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  decoration: InputDecoration(
                    //icon: Icon(Icons.email, color: Colors.white70),
                    hintText: "New password...",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(5.0),
                      ),
                    ),
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.only(left: 20.0),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
              )
            ],
          )),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                resetPasswordEmailPasswordController.clear();
                oldPasswordController.clear();
                newPasswordController.clear(); // Dismiss alert dialog
              },
            ),
            FlatButton(
              child: Text('Send'),
              onPressed: () {
                changePassword(resetPasswordEmailPasswordController.text,
                    oldPasswordController.text, newPasswordController.text);
              },
            ),
          ],
        );
      },
    );
  }

  createAlertDialog3(BuildContext context) {
    return showDialog<void>(
      context: context,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Center(
            child: Text('Forgot password?',
                style: TextStyle(color: Colors.grey, fontSize: 17)),
          ),
          content: SingleChildScrollView(
              //height: 180.0,
              //padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: new Column(
            children: <Widget>[
//                Text('Please enter your email and'),
//                Text('password to reset.'),
              Wrap(
                children: <Widget>[
                  Center(child: Text('Please enter your email')),
                  Center(child: Text('address to receive reset link.'))
                ],
              ),
              Container(
                height: 30.0,
                margin: EdgeInsets.only(top: 10.0, bottom: 0.0),
                padding: EdgeInsets.only(left: 0.0),
                child: TextFormField(
                  controller: resetemailController,
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black, fontSize: 15),
                  decoration: InputDecoration(
                    //icon: Icon(Icons.email, color: Colors.white70),
                    hintText: "Email...",
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black),
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(5.0),
                      ),
                    ),
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: const EdgeInsets.only(left: 20.0),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
              ),
            ],
          )),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                emailController.clear();
                // Dismiss alert dialog
              },
            ),
            FlatButton(
              child: Text('Send'),
              onPressed: () {
                sendMail(resetemailController.text);
              },
            ),
          ],
        );
      },
    );
  }
}
