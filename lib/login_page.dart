import 'package:flutter/material.dart';

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
          child: Column(
            children: <Widget>[
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
                  onPressed: () {
                    // save the fields..
                    final form = _formKey.currentState;
                    form.save();

                    // Validate will return true if is valid, or false if invalid.
                    if (form.validate()) {
                      print("$_email $_password");
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
