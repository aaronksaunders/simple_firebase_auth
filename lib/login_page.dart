import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _password;
  String _email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Login Page Flutter Firebase"),
        ),
        body: Container(
            padding: EdgeInsets.all(20.0),
            child: Form(
                key: _formKey,
                child: Column(children: <Widget>[
                  SizedBox(height: 20.0),
                  Text(
                    'Login Information',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                      onSaved: (value) => _email = value,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: "Email Address")),
                  TextFormField(
                      onSaved: (value) => _password = value,
                      obscureText: true,
                      decoration: InputDecoration(labelText: "Password")),
                  SizedBox(height: 20.0),
                  RaisedButton(
                      child: Text("LOGIN"),
                      onPressed: () async {
                        // save the fields..
                        final form = _formKey.currentState;
                        form.save();

                        // Validate will return true if is valid, or false if invalid.
                        if (form.validate()) {
                          var result = await Provider.of<AuthService>(context)
                              .loginUser(email: _email, password: _password);
                          if (result != null) {
                            //Navigator.pushReplacementNamed(context, "/");
                          } else {
                            return _buildShowErrorDialog(context,
                                "Error Logging In With Those Credentials");
                          }
                        }
                      })
                ]))));
  }

  Future _buildShowErrorDialog(BuildContext context, _message) {
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
}
