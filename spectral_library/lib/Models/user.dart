import 'package:spectral_library/Models/folder.dart';
import 'package:spectral_library/Models/user_type.dart';

class User {
  int? userId;
  String email;
  String password;
  UserType type;
  bool isConfirmed;
  String company;
  String? token;
  List<Folder>? folders;
  User({
    this.userId,
    required this.email,
    required this.password,
    required this.type,
    required this.isConfirmed,
    required this.company,
    this.token,
    this.folders,
  });
}
