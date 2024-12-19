import 'package:spectral_library/Controllers/request.dart';
import 'package:spectral_library/Models/response.dart';
import 'package:spectral_library/Models/user.dart';

class AdminController {
  static Future<Response> getUserCount(User user) async {
    return await Request.get(user, "Admin/UserCount");
  }

  static Future<Response> getFileCount(User user) async {
    return await Request.get(user, "Admin/FileCount");
  }

  static Future<Response> getFolderCount(User user) async {
    return await Request.get(user, "Admin/FolderCount");
  }

  static Future<Response> getFileCategoryRatios(User user) async {
    return await Request.get(user, "Admin/FileCategoryRatios");
  }
}
