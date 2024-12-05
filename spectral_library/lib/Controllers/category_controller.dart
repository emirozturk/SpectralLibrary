import 'package:spectral_library/Controllers/request.dart';
import 'package:spectral_library/Models/response.dart';
import 'package:spectral_library/Models/user.dart';

class CategoryController {
  static Future<Response> getCategories(User user) async {
    return await Request.get(user, "Categories");
  }
}
