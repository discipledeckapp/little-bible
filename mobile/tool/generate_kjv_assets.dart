import 'dart:convert';
import 'dart:io';

import 'package:little_bible/core/data/bible_canon.dart';

/// Generates KJV-only chapter assets without overwriting chapters that already
/// contain Little Bible Version (LBV) text.
///
/// Usage from the repository root:
///   dart run mobile/tool/generate_kjv_assets.dart
///   dart run mobile/tool/generate_kjv_assets.dart path/to/kjv.json
void main(List<String> arguments) {
  final toolDirectory = File.fromUri(Platform.script).parent;
  final mobileDirectory = toolDirectory.parent;
  final source = arguments.isEmpty
      ? File('${toolDirectory.path}/data/kjv.json')
      : File(arguments.first).absolute;

  if (!source.existsSync()) {
    stderr.writeln('KJV source not found: ${source.path}');
    exitCode = 2;
    return;
  }

  final decoded = jsonDecode(source.readAsStringSync());
  final versesByBook = _parseSource(decoded);
  _validateSource(versesByBook);

  final assetsRoot = Directory('${mobileDirectory.path}/assets/bible/en');
  var writtenChapters = 0;
  var skippedLbvChapters = 0;
  var writtenBooks = 0;

  for (var bookIndex = 0; bookIndex < kBibleBooks.length; bookIndex++) {
    final definition = kBibleBooks[bookIndex];
    final chapters = versesByBook[bookIndex + 1]!;
    final bookDirectory = Directory('${assetsRoot.path}/${definition.key}')
      ..createSync(recursive: true);
    var bookWrites = 0;

    for (var chapter = 1; chapter <= definition.chapterCount; chapter++) {
      final output = File(
        '${bookDirectory.path}/${definition.key}_chapter_${chapter.toString().padLeft(2, '0')}.json',
      );

      if (_containsLbv(output)) {
        skippedLbvChapters++;
        continue;
      }

      final chapterVerses = chapters[chapter];
      if (chapterVerses == null || chapterVerses.isEmpty) {
        throw StateError(
          '${definition.displayName} $chapter is missing from the KJV source',
        );
      }

      final document = <String, Object>{
        'book': definition.displayName,
        'chapter': chapter,
        'verses': [
          for (final entry in chapterVerses.entries)
            <String, Object>{'verse': entry.key, 'kjv': entry.value},
        ],
      };
      output.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(document)}\n',
      );
      writtenChapters++;
      bookWrites++;
    }

    if (bookWrites > 0) writtenBooks++;
    stdout.writeln(
      '[${(bookIndex + 1).toString().padLeft(2, '0')}/66] '
      '${definition.displayName}: $bookWrites chapter(s) written',
    );
  }

  stdout.writeln(
    'Complete: $writtenChapters chapters written across $writtenBooks books; '
    '$skippedLbvChapters LBV chapters preserved.',
  );
}

/// Supports both the requested numeric row format and the equivalent
/// public-domain farskipper map format ("Genesis 1:1": "text").
Map<int, Map<int, Map<int, String>>> _parseSource(Object? decoded) {
  final result = <int, Map<int, Map<int, String>>>{};
  if (decoded is List) {
    for (final raw in decoded) {
      if (raw is! Map) throw const FormatException('KJV row must be an object');
      _addVerse(
        result,
        _asInt(raw['b'], 'b'),
        _asInt(raw['c'], 'c'),
        _asInt(raw['v'], 'v'),
        _asText(raw['t']),
      );
    }
    return result;
  }

  if (decoded is Map) {
    final bookNumbers = <String, int>{
      for (var i = 0; i < kBibleBooks.length; i++)
        kBibleBooks[i].displayName: i + 1,
      "Solomon's Song": 22,
    };
    final referencePattern = RegExp(r'^(.+) (\d+):(\d+)$');
    for (final entry in decoded.entries) {
      final match = referencePattern.firstMatch(entry.key.toString());
      if (match == null) {
        throw FormatException('Invalid KJV reference: ${entry.key}');
      }
      final sourceBook = match.group(1)!;
      final book = bookNumbers[sourceBook];
      if (book == null) throw FormatException('Unknown KJV book: $sourceBook');
      _addVerse(
        result,
        book,
        int.parse(match.group(2)!),
        int.parse(match.group(3)!),
        _asText(entry.value),
      );
    }
    return result;
  }

  throw const FormatException('KJV JSON must be a list or an object');
}

void _addVerse(
  Map<int, Map<int, Map<int, String>>> result,
  int book,
  int chapter,
  int verse,
  String text,
) {
  result.putIfAbsent(book, () => {}).putIfAbsent(chapter, () => {})[verse] =
      text.replaceFirst(RegExp(r'^#\s*'), '');
}

void _validateSource(Map<int, Map<int, Map<int, String>>> source) {
  if (source.length != 66) {
    throw StateError('Expected 66 books, found ${source.length}');
  }
  var verseCount = 0;
  for (var i = 0; i < kBibleBooks.length; i++) {
    final definition = kBibleBooks[i];
    final chapters = source[i + 1];
    if (chapters == null || chapters.length != definition.chapterCount) {
      throw StateError(
        '${definition.displayName}: expected ${definition.chapterCount} chapters, '
        'found ${chapters?.length ?? 0}',
      );
    }
    for (final chapter in chapters.values) {
      verseCount += chapter.length;
      final numbers = chapter.keys.toList()..sort();
      for (var index = 0; index < numbers.length; index++) {
        if (numbers[index] != index + 1) {
          throw StateError(
            '${definition.displayName}: non-sequential verse numbering',
          );
        }
      }
    }
  }
  if (verseCount != 31102) {
    throw StateError('Expected 31,102 verses, found $verseCount');
  }
}

bool _containsLbv(File file) {
  if (!file.existsSync()) return false;
  final decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! Map || decoded['verses'] is! List) return false;
  return (decoded['verses'] as List).any((raw) {
    if (raw is! Map) return false;
    final value = raw['little_bible'];
    return value is String && value.trim().isNotEmpty;
  });
}

int _asInt(Object? value, String field) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('KJV field $field must be an integer');
}

String _asText(Object? value) {
  if (value is! String || value.trim().isEmpty) {
    throw const FormatException('KJV verse text must be a non-empty string');
  }
  return value.trim();
}
