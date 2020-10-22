import 'dart:io';

import 'package:downloads_path_provider_28/downloads_path_provider_28.dart';
import 'package:file_chooser/file_chooser.dart' as file_chooser;
import 'package:file_chooser/file_chooser.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<FileChooserResult> chooseFileDesktop(String filename,
    final String fileLabel, final List<String> fileExtentions) async {
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

Future<List<dynamic>> getMobileLocalFolder() async {
  final dir = await _getDownloadDirectory();
  final isPermissionStatusGranted = await _requestPermissions();

  if (isPermissionStatusGranted == 0) {
    print(dir.path);
    return [true, File("${dir.path}")];
  }
  return [false, isPermissionStatusGranted];
}

Future<Directory> _getDownloadDirectory() async {
  if (Platform.isAndroid) {
    return await DownloadsPathProvider.downloadsDirectory;
  }

  // in this example we are using only Android and iOS so I can assume
  // that you are not trying it for other platforms and the if statement
  // for iOS is unnecessary

  // iOS directory visible to user
  return await getApplicationDocumentsDirectory();
}

Future<int> _requestPermissions() async {
  var permission = await Permission.storage.status;

  if (permission != PermissionStatus.granted) {
    await Permission.storage.request();
    permission = await Permission.storage.status;
  }
  if (permission.isPermanentlyDenied) {
    // The user opted to never again see the permission request dialog for this
    // app. The only way to change the permission's status now is to let the
    // user manually enable it in the system settings.

  }

  if (permission == PermissionStatus.granted) return 0;
  if (permission == PermissionStatus.denied) return 1;
  return 2;
}
