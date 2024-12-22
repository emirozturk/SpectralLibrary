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

  static Future<Response> resetPassword(String email) async {
    return await Request.postWithoutAuth(
        "Users/ResetPassword",
        User(
            email: email,
            password: "",
            type: UserType.user,
            isConfirmed: false,
            company: ""));
  }

  static Future<Response> register(User newUser) async {
    return await Request.postWithoutAuth("Users/", newUser);
  }

  static Future<Response> updateUser(User admin, User user) async {
    return await Request.put(admin, "Users/", user);
  }

  static Future<Response> deleteUser(User user, String email) async {
    return await Request.delete(user, "Users/$email", null);
  }

  static Future<Response> getPublicFiles(User user) async {
    return await Request.get(user, "PublicFiles");
  }

  static Future<Response> getSharedFiles(User user) async {
    return await Request.get(user, "SharedFiles");
  }

  static Future<Response> getUsers(User user) async {
    return await Request.get(user, "Users/");
  }
}
