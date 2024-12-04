import 'package:spectral_library/Models/data.dart';

//Dart.io altındaki file class'ı ile karışmaması için bu isim verildi
class SpectFile {
  int? fileId;
  String filename;
  String category;
  String? description;
  bool isPublic;
  List<Data> dataPoints;
  List<String>? sharedWith;
  SpectFile(
      {this.fileId,
      required this.filename,
      required this.category,
      required this.isPublic,
      required this.dataPoints,
      this.description,
      this.sharedWith});
  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'filename': filename,
      'category': category,
      'description': description,
      'isPublic': isPublic,
      'dataPoints': dataPoints.map((data) => data.toMap()).toList(),
      'sharedWith': sharedWith,
    };
  }

  /// Creates a SpectFile object from a Map
  factory SpectFile.fromMap(Map<String, dynamic> map) {
    return SpectFile(
      fileId: map['fileId'] as int?,
      filename: map['filename'] as String,
      category: map['category'] as String,
      description: map['description'] as String?,
      isPublic: map['isPublic'] as bool,
      dataPoints: (map['dataPoints'] as List<dynamic>)
          .map((dataMap) => Data.fromMap(dataMap as Map<String, dynamic>))
          .toList(),
      sharedWith: (map['sharedWith'] as List<dynamic>?)
          ?.map((item) => item as String)
          .toList(),
    );
  }
}
