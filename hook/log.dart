import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:logging/logging.dart';

Logger createLogger(String outputDirectory, String logFilename) {
  final logFile = File(path.join(outputDirectory, logFilename));

  final logger = Logger("")
    ..level = Level.ALL
    ..onRecord.listen(
      (record) => logFile.writeAsStringSync(
        '${record.message}\n',
        mode: FileMode.append,
        flush: true,
      ),
    );
  return logger;
}
