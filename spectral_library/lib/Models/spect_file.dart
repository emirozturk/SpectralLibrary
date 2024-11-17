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
}
