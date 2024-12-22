import 'package:spectral_library/Models/category.dart';
import 'package:spectral_library/Models/data.dart';

class SpectFile {
  int? fileId;
  String filename;
  Category category;
  String? description;
  bool isPublic;
  List<Data> dataPoints;
  List<String>? sharedWith;

  SpectFile({
    this.fileId,
    required this.filename,
    required this.category,
    required this.isPublic,
    required this.dataPoints,
    this.description,
    this.sharedWith,
  });

  /// Convert a SpectFile object to a Map for serialization
  Map<String, dynamic> toMap() {
    return {
      'fileId': fileId,
      'filename': filename,
      // Use category.toMap() instead of just category
      'category': category.toMap(),
      'description': description,
      'isPublic': isPublic,
      'dataPoints': dataPoints.map((data) => data.toMap()).toList(),
      'sharedWith': sharedWith,
    };
  }

  /// Create a SpectFile object from a Map
  factory SpectFile.fromMap(Map<String, dynamic> map) {
    return SpectFile(
      fileId: map['fileId'] as int?,
      filename: map['filename'] as String,
      // Convert the category map into a Category object
      category: Category.fromMap(map['category'] as Map<String, dynamic>),
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
