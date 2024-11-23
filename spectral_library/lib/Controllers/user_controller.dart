import 'package:spectral_library/Controllers/request.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/util.dart';

class UserController {
  static getUser(String email, String password) async {
    var md5 = Util.calculateMD5(password);
    return await Request.postWithoutAuth(
        "Users/CheckLogin", {"email": email, "password": md5});
  }

  static resetPassword(String text) {}

  static register(User newUser) {}
}
