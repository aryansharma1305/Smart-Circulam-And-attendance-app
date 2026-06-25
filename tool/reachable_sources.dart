import 'dart:io';

void main() {
  final pending = <File>[File('lib/main.dart')];
  final visited = <String>{};

  while (pending.isNotEmpty) {
    final file = pending.removeLast();
    final path = file.absolute.path;
    if (!file.existsSync() || !visited.add(path)) {
      continue;
    }

    for (final line in file.readAsLinesSync()) {
      final match = RegExp(r'''^import\s+['"]([^'"]+)['"]''').firstMatch(line);
      final importPath = match?.group(1);
      if (importPath == null ||
          importPath.startsWith('dart:') ||
          importPath.startsWith('package:')) {
        continue;
      }

      pending.add(File.fromUri(file.parent.uri.resolve(importPath)));
    }
  }

  final workspace = Directory.current.absolute.path;
  final sources =
      visited.map((path) => path.replaceFirst('$workspace/', '')).toList()
        ..addAll(
          Directory('test')
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))
              .map((file) => file.path),
        )
        ..sort();

  stdout.write(sources.join('\n'));
}
