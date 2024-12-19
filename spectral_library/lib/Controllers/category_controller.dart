import 'package:spectral_library/Controllers/request.dart';
import 'package:spectral_library/Models/category.dart';
import 'package:spectral_library/Models/response.dart';
import 'package:spectral_library/Models/user.dart';

class CategoryController {
  static Future<Response> getCategories(User user) async {
    return await Request.get(user, "Categories");
  }

  static addCategory(User user, Category newCategory) async {
    return await Request.post(user, "Categories", newCategory);
  }

  static updateCategory(User user, Category category) async {
    return await Request.put(user, "Categories", category);
  }

  static deleteCategory(User user, Category category) async {
    return await Request.delete(user, "Categories", category);
  }
}
