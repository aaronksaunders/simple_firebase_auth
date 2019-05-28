import 'dart:async';

class AuthService {
  var currentUser;

  AuthService() {
    print("new AuthService");
  }

  Future getUser() {
    return Future.value(currentUser);
  }

  // wrappinhg the firebase calls
  Future logout() {
    this.currentUser =  null;
    return Future.value(currentUser);
  }

  // wrappinhg the firebase calls
  Future createUser(
      {String firstName,
      String lastName,
      String email,
      String password}) async {}

  // wrappinhg the firebase calls
  Future loginUser({String email, String password}) {
    this.currentUser =  {'email': email};
    return Future.value(currentUser);
  }
}
