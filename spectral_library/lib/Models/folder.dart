import 'package:spectral_library/Models/spect_file.dart';

class Folder {
  int? folderId;
  String folderName;
  List<SpectFile> files;
  Folder(
      {this.folderId, required this.folderName, required this.files});
}
