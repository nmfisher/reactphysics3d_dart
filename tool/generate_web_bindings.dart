import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

/// Usage: EMSDK=/path/to/emsdk dart run tool/generate_web_bindings.dart
Future<void> main() async {
  final emsdk = Platform.environment['EMSDK'];
  if (emsdk == null)
    throw StateError('Set EMSDK to the Emscripten SDK directory');
  final root = Directory.current.path;
  final configDir = path.join(root, 'ffigen');
  final config = Map<String, dynamic>.from(
    loadYaml(File(path.join(configDir, 'web.yaml')).readAsStringSync()) as Map,
  );
  final sysroot = path.join(
    emsdk,
    'upstream',
    'emscripten',
    'cache',
    'sysroot',
  );
  config['compiler-opts'] = [
    ...config['compiler-opts'] as List,
    '--sysroot=$sysroot',
    '-isystem',
    path.join(sysroot, 'include'),
  ];
  config['output'] = path.normalize(
    path.join(configDir, config['output'] as String),
  );
  config['headers'] = {
    'entry-points': [path.join(root, 'native/include/c_api/rp3d_c_api.h')],
    'include-directives': [
      path.join(root, 'native/include/c_api/rp3d_c_api.h'),
    ],
  };
  final temp = Directory.systemTemp.createTempSync('rp3d-bindings-');
  try {
    final file = File(path.join(temp.path, 'config.yaml'))
      ..writeAsStringSync(jsonEncode(config));
    final process = await Process.start(Platform.resolvedExecutable, [
      'run',
      'ffigen_js',
      '--config',
      file.path,
    ], mode: ProcessStartMode.inheritStdio);
    exitCode = await process.exitCode;
  } finally {
    temp.deleteSync(recursive: true);
  }
}
