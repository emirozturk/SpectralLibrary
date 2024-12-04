import 'package:spectral_library/Controllers/request.dart';
import 'package:spectral_library/Models/response.dart';
import 'package:spectral_library/Models/user.dart';
import 'package:spectral_library/Models/user_type.dart';

class UserController {
  static Future<Response> getUser(String email, String password) async {
    return await Request.postWithoutAuth(
        "Users/CheckLogin",
        User(
            email: email,
            password: password,
            type: UserType.user,
            isConfirmed: true,
            company: ""));
  }

  static Response resetPassword(String text) {
    return Response(false, "", "");
  }

  static Response register(User newUser) {
    return Response(false, "", "");
  }

  static Future<Response> updateUser(User user) async {
    return await Request.put(user, "Users/", user);
  }
}
