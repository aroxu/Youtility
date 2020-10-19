import 'package:Youtility/global.dart';

void updateLogMessage(String log) {
  logMessage += "${new DateTime.now()}: $log\n";
}

void clearLogMessage() {
  logMessage = "${new DateTime.now()}: Cleared Log by user request.\n";
}
