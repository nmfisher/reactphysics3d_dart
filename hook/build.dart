import 'dart:io';
import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';
import 'package:path/path.dart' as path;
import 'log.dart';

void main(List<String> args) async {
  await build(args, (BuildInput input, BuildOutputBuilder output) async {
    final packageRoot = input.packageRoot;
    final pkgRootFilePath = packageRoot.toFilePath(windows: Platform.isWindows);

    final outputDirectory = input.outputDirectory;
    final logger = createLogger(outputDirectory.toFilePath(), "build.log");

    if (!input.config.buildCodeAssets) {
      logger.info("buildCodeAssets is false, assumed to be building for web");
      return;
    }

    final config = input.config;
    var buildMode = BuildMode.release;

    final packageName = input.packageName;
    final targetOS = config.code.targetOS;

    logger.info("""
packageRoot: $packageRoot
outputDirectory: ${outputDirectory.path}
targetOS: $targetOS
""");

    // Source files
    var sources = [
      path.join(pkgRootFilePath, "native/src/rp3d_c_api.cpp"),
      path.join(pkgRootFilePath, "native/src/dart_sendport_listener.cpp"),
    ];

    // Include directories - need both our C API headers and ReactPhysics3D headers
    final sdkInclude = path.join(
      path.dirname(path.dirname(Platform.resolvedExecutable)),
      'include',
    );
    final includeDirs = [
      path.join(pkgRootFilePath, "native/include"),
      sdkInclude,
    ];

    final targetArchitecture = config.code.targetArchitecture;

    // The prebuilt libraries are laid out by compiler triple name, where Dart's
    // x64 architecture is called x86_64.
    final archDirName = targetArchitecture.name == "x64"
        ? "x86_64"
        : targetArchitecture.name;

    // Library directories
    final libDirs = <String>[
      if (targetOS == OS.macOS) ...[
        path.join(pkgRootFilePath, "native/macos", archDirName),
        path.join(pkgRootFilePath, "native/macos"),
      ],
      if (targetOS == OS.linux)
        path.join(pkgRootFilePath, "native/linux", archDirName),
      if (targetOS == OS.windows) ...[
        path.join(pkgRootFilePath, "native/windows", archDirName),
        path.join(pkgRootFilePath, "native/windows"),
      ],
    ];

    // Libraries to link against
    var libs = [
      "reactphysics3d", // ReactPhysics3D static library
    ];

    final defines = <String, String?>{};
    final flags = <String>[
      if (targetOS == OS.linux) "-pthread",
    ];

    var frameworks = <String>[];

    if (targetOS != OS.windows) {
      flags.addAll(libDirs.map((dir) => "-L$dir"));
    } else {
      defines["WIN32"] = "1";
      defines["_DLL"] = "1";
      defines["NOMINMAX"] = "1";
      defines["WIN32_LEAN_AND_MEAN"] = "1";
      if (buildMode == BuildMode.debug) {
        defines["_DEBUG"] = "1";
      } else {
        defines["RELEASE"] = "1";
        defines["NDEBUG"] = "1";
      }

      flags.addAll([
        "/EHsc",
        "/FIchrono",
        if (buildMode == BuildMode.debug) ...["/MDd", "/Zi"],
        if (buildMode == BuildMode.release) "/MD",
      ]);
    }

    if (targetOS == OS.macOS) {
      frameworks.addAll(['Foundation', 'CoreVideo', 'Cocoa']);

      if (buildMode == BuildMode.debug) {
        flags.addAll(["-g", "-O0"]);
      }
    }

    frameworks = frameworks.expand((f) => ["-framework", f]).toList();

    logger.info("Sources: $sources");
    logger.info("Libraries: $libs");
    logger.info("Defines: $defines");
    logger.info("Flags: $flags");
    logger.info("Include directories: $includeDirs");
    logger.info("Library directories: $libDirs");

    if (sources.isNotEmpty) {
      final cbuilder = CBuilder.library(
        name: packageName,
        language: Language.cpp,
        std: 'c++17',
        assetName: 'reactphysics3d_dart.dart',
        sources: sources,
        includes: includeDirs,
        defines: defines,
        libraries: targetOS == OS.windows ? libs : const [],
        libraryDirectories: libDirs,
        flags: [
          if (targetOS == OS.macOS) '-mmacosx-version-min=13.0',
          ...flags,
          ...frameworks,
          if (targetOS != OS.windows) ...[
            if (targetOS == OS.linux) ...[
              '-Wl,--whole-archive',
              ...libs.map((lib) => "-l$lib"),
              '-Wl,--no-whole-archive',
            ] else
              ...libs.map((lib) => "-l$lib"),
            "-lstdc++",
          ],
        ],
      );

      logger.info("Running CBuilder...");

      output.metadata.addAll({"includeDirs": includeDirs});
      output.metadata.addAll({"outputDir": outputDirectory.path});

      await cbuilder.run(input: input, output: output, logger: logger);
      logger.info("Build completed successfully");
    } else {
      logger.info("No sources found, skipping build");
    }
  });
}
