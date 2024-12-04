import 'package:spectral_library/Models/spect_file.dart';

class Folder {
  int? folderId;
  String folderName;
  List<SpectFile>? files;
  Folder({this.folderId, required this.folderName, this.files});
  Map<String, dynamic> toMap() {
    return {
      'folderId': folderId,
      'folderName': folderName,
      'files': files?.map((file) => file.toMap()).toList(),
    };
  }

  /// Creates a Folder object from a Map
  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      folderId: map['folderId'] as int?,
      folderName: map['folderName'] as String,
      files: (map['files'] as List<dynamic>)
          .map((fileMap) => SpectFile.fromMap(fileMap as Map<String, dynamic>))
          .toList(),
    );
  }
}
