import 'package:spectral_library/Models/folder.dart';
import 'package:spectral_library/Models/spect_file.dart';
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
  List<SpectFile>? sharedFiles;
  List<SpectFile>? publicFiles;
  User({
    this.userId,
    required this.email,
    required this.password,
    required this.type,
    required this.isConfirmed,
    required this.company,
    this.token,
    this.folders,
    this.sharedFiles,
    this.publicFiles,
  });
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'password': password,
      'type': type.toStringValue(), // Assuming UserType is an enum
      'isConfirmed': isConfirmed,
      'company': company,
      'token': token,
      'folders': folders?.map((folder) => folder.toMap()).toList(),
    };
  }

  /// Creates a User object from a Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['userId'] as int?,
      email: map['email'] as String,
      password: map['password'] as String,
      type: UserTypeExtension.fromString(
          map['type']), // Assuming UserType is an enum
      isConfirmed: map['isConfirmed'] as bool,
      company: map['company'] as String,
      token: map['token'] as String?,
      folders: (map['folders'] as List<dynamic>?)
          ?.map(
              (folderMap) => Folder.fromMap(folderMap as Map<String, dynamic>))
          .toList(),
      sharedFiles: (map['sharedFiles'] as List<dynamic>?)
          ?.map((x) => SpectFile.fromMap(x))
          .toList(),
      publicFiles: (map['publicFiles'] as List<dynamic>?)
          ?.map((x) => SpectFile.fromMap(x))
          .toList(),
    );
  }
}
