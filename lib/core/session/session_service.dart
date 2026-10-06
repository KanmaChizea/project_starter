import 'package:flutter/foundation.dart';

import 'user.dart';

/// App-wide record of who is signed in. Listen to react to sign-in/sign-out.
///
/// Written by the auth feature; read by routing, networking and other features.
class SessionService extends ChangeNotifier {
  User? _user;
  User? get user => _user;

  bool get isSignedIn => _user != null;

  void start(User user) {
    _user = user;
    notifyListeners();
  }

  void clear() {
    if (_user == null) return;
    _user = null;
    notifyListeners();
  }
}
