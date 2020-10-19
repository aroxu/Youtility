import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:file_chooser/file_chooser.dart';

Future<FileChooserResult> chooseFile(String filename, final String fileLabel,
    final List<String> fileExtentions) async {
  return await file_chooser.showSavePanel(
    suggestedFileName: filename
        .replaceAll(r'\', '')
        .replaceAll('/', '')
        .replaceAll('*', '')
        .replaceAll('?', '')
        .replaceAll('"', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('|', ''),
    allowedFileTypes: [
      file_chooser.FileTypeFilterGroup(
        label: fileLabel,
        fileExtensions: fileExtentions,
      )
    ],
  );
}
