#!/usr/bin/env dart
// Publishes the SDK and its sibling packages.
//
// Pub walks ignore files from the git repository root, so the root .pubignore
// that keeps the apps out of the SDK archive also hides the sibling packages
// when publishing them directly. This tool stages each sibling package in a
// temporary directory (dropping the local pubspec_overrides.yaml), then runs
// `dart pub publish` there.
//
// Usage:
//   dart run tool/publish.dart <sdk|effect|genkit|all> [pub publish options]
//
// Options are forwarded to `dart pub publish`, for example:
//   dart run tool/publish.dart all --dry-run
//
// Publish in dependency order: sdk, then effect, then genkit.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const _packageDirs = <String, String>{
  'sdk': '.',
  'effect': 'opencode_effect',
  'genkit': 'genkit_opencode_custom',
};

const _publishOrder = ['sdk', 'effect', 'genkit'];

Future<void> main(List<String> args) async {
  final targets = <String>[];
  final options = <String>[];

  for (final arg in args) {
    if (arg == 'all') {
      targets.addAll(_publishOrder);
    } else if (_packageDirs.containsKey(arg)) {
      targets.add(arg);
    } else {
      options.add(arg);
    }
  }

  if (targets.isEmpty) {
    stderr.writeln(
      'Usage: dart run tool/publish.dart '
      '<sdk|effect|genkit|all> [pub publish options]',
    );
    stderr.writeln(
      'Options are forwarded to `dart pub publish` (for example --dry-run).',
    );
    exitCode = 64;
    return;
  }

  final selected = _publishOrder.where(targets.contains).toList();

  try {
    final repoRoot = p.normalize(
      (await _git(['rev-parse', '--show-toplevel'])).trim(),
    );
    for (final target in selected) {
      await _publish(repoRoot, target, options);
    }
  } on ProcessException catch (error) {
    stderr.writeln(error.message);
    if (error.errorCode != 0) exitCode = error.errorCode;
  }
}

Future<void> _publish(
  String repoRoot,
  String target,
  List<String> options,
) async {
  final packageDir = _packageDirs[target]!;
  if (packageDir == '.') {
    stdout.writeln('Publishing $target from the repository root...');
    await _run(['dart', 'pub', 'publish', ...options], repoRoot);
    return;
  }

  final sourceDir = p.join(repoRoot, packageDir);
  final tempDir = await Directory.systemTemp.createTemp(
    'opencode_publish_${target}_',
  );

  try {
    final files = await _gitFiles(repoRoot, packageDir);
    for (final repoRelative in files) {
      final packageRelative = p.relative(
        p.join(repoRoot, repoRelative),
        from: sourceDir,
      );
      if (p.split(packageRelative).first == '..') continue;

      // Local path overrides and local state must not reach pub.dev.
      if (_skipInStaging(packageRelative)) continue;

      final destination = p.join(tempDir.path, packageRelative);
      final source = File(p.join(repoRoot, repoRelative));
      if (!source.existsSync()) continue;
      Directory(p.dirname(destination)).createSync(recursive: true);
      source.copySync(destination);
    }

    stdout.writeln('Publishing $target from a clean staging copy...');
    await _run(['dart', 'pub', 'publish', ...options], tempDir.path);
  } finally {
    await tempDir.delete(recursive: true);
  }
}

bool _skipInStaging(String packageRelative) {
  final segments = p.split(packageRelative);
  if (segments.any(
    (segment) =>
        segment == 'build' ||
        segment == '.dart_tool' ||
        segment == 'coverage' ||
        segment == 'DerivedData',
  )) {
    return true;
  }

  final basename = p.basename(packageRelative);
  if (basename == 'pubspec_overrides.yaml' || basename == 'pubspec.lock') {
    return true;
  }
  if (basename == '.DS_Store' ||
      basename == '.env' ||
      basename.startsWith('.env.') ||
      basename == 'secrets.json' ||
      basename == 'service.json' ||
      basename == 'credentials.json') {
    return true;
  }
  return basename.endsWith('.pem') ||
      basename.endsWith('.key') ||
      basename.endsWith('.p12') ||
      basename.endsWith('.provisionprofile') ||
      basename.endsWith('.mobileprovision');
}

Future<List<String>> _gitFiles(String repoRoot, String packageDir) async {
  final result = await Process.run(
    'git',
    [
      '-c',
      'core.quotePath=false',
      'ls-files',
      '-z',
      '--cached',
      '--others',
      '--exclude-standard',
      '--',
      packageDir,
    ],
    workingDirectory: repoRoot,
    stdoutEncoding: null,
    stderrEncoding: utf8,
  );

  if (result.exitCode != 0) {
    throw ProcessException(
      'git',
      ['ls-files'],
      '${result.stderr}'.trim(),
      result.exitCode,
    );
  }

  return utf8
      .decode(result.stdout as List<int>)
      .split('\u0000')
      .where((path) => path.isNotEmpty)
      .toList();
}

Future<String> _git(List<String> args) async {
  final result = await Process.run(
    'git',
    args,
    stderrEncoding: utf8,
  );

  if (result.exitCode != 0) {
    throw ProcessException(
      'git',
      args,
      '${result.stderr}'.trim(),
      result.exitCode,
    );
  }

  return '${result.stdout}';
}

Future<void> _run(List<String> command, String workingDirectory) async {
  final process = await Process.start(
    command.first,
    command.sublist(1),
    workingDirectory: workingDirectory,
    mode: ProcessStartMode.inheritStdio,
  );
  final code = await process.exitCode;
  if (code != 0) {
    throw ProcessException(
      command.first,
      command.sublist(1),
      'exited with code $code',
      code,
    );
  }
}
