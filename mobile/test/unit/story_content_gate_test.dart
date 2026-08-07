import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_bible/core/models/story_model.dart';

// Enforces the machine-checkable half of the pre-launch content gate in
// docs/LittleBible_Delivery_Plan.md against every bundled story package.
//
// What this test CANNOT check, and which stays with human reviewers: whether the
// genre's narrative beats are actually present in the prose, whether the doctrinal
// checklist passes, and whether the sensitivity tier is the *correct* one for the
// content. Those approvals are recorded in the admin review workflow, not here.
// This test only guarantees that no package reaches a child missing a required
// declaration.

/// Genres from the "Genre-aware structure requirement" table in the delivery plan.
const _validGenres = {
  'narrative',
  'wisdom',
  'lament',
  'teaching',
  'parable',
  'poetry',
};

const _validTiers = {'general', 'guided', 'parental_presence'};

/// Stories the plan names as requiring at least `guided` classification because
/// they contain peril, death or morally complex outcomes. Listed by story id.
const _minimumGuided = {
  'god-provides-a-lamb', // near-harm of a child
  'noahs-big-boat', // flood
  'the-passover-lamb', // death of the firstborn
  'daniel-and-the-lions', // peril
  'jesus-saves', // crucifixion
  'two-brothers', // human death
  'the-very-sad-choice', // the fall
  'davids-sin-and-gods-mercy', // adultery and a death arranged to hide it
  'elijah-and-the-only-true-god', // idolatry, and a contest with real stakes
};

/// Collected at load time so each package can declare its own `group`, which
/// names the offending story in the failure output.
List<File> _storyFiles() {
  final dir = Directory('assets/stories');
  if (!dir.existsSync()) return const [];
  return dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json')).toList()
    ..sort((a, b) => a.path.compareTo(b.path));
}

void main() {
  final files = _storyFiles();

  test('the bundled story catalogue is discoverable', () {
    expect(files, isNotEmpty,
        reason: 'assets/stories must contain the bundled packages');
  });

  test('every story package parses into a StoryModel', () {
    for (final file in files) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      expect(
        () => StoryModel.fromJson(json),
        returnsNormally,
        reason: '${file.path} failed to parse',
      );
    }
  });

  group('package-level declarations', () {
    for (final file in files) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final story = StoryModel.fromJson(json);

      group(story.id, () {
        test('declares a valid sensitivityTier', () {
          // Absent is not the same as `general` — the gate requires a decision to
          // have been made, so check the raw JSON rather than the model default.
          expect(json.containsKey('sensitivityTier'), isTrue,
              reason: 'sensitivityTier must be declared explicitly');
          expect(_validTiers, contains(story.sensitivityTier));
        });

        test('declares a valid genre', () {
          expect(json.containsKey('genre'), isTrue,
              reason: 'genre must be declared explicitly');
          expect(_validGenres, contains(story.genre));
        });

        test('declares a one-sentence verseContext', () {
          expect(json.containsKey('verseContext'), isTrue,
              reason: 'verseContext must be declared explicitly');
          final context = story.verseContext.trim();
          expect(context, isNotEmpty);
          expect(context.length, greaterThan(30),
              reason: 'verseContext must give real narrative context, not a stub');
          expect(context.length, lessThanOrEqualTo(220),
              reason: 'verseContext is one sentence, not a paragraph');
          expect(context.endsWith('.'), isTrue,
              reason: 'verseContext should read as a complete sentence');
          expect(context.contains('\n'), isFalse);
        });

        test('carries every beat-bearing field', () {
          // Each genre template in the plan needs a context beat, the passage
          // itself, a stated meaning, and a reflection or application beat.
          expect(story.verseContext.trim(), isNotEmpty, reason: 'context beat');
          expect(story.steps.read.childText.trim(), isNotEmpty, reason: 'passage beat');
          expect(story.mainTruth.trim(), isNotEmpty, reason: 'meaning beat');
          expect(story.steps.discuss.question.trim(), isNotEmpty,
              reason: 'reflection beat');
          expect(story.steps.doToday.action.trim(), isNotEmpty,
              reason: 'application beat');
        });

        test('key verse is present with a reference', () {
          expect(story.steps.remember.memoryVerse.trim(), isNotEmpty);
          expect(story.steps.remember.ref.trim(), isNotEmpty);
        });

        if (_minimumGuided.contains(story.id)) {
          test('is classified at least `guided`', () {
            expect(story.sensitivityTier, isNot('general'),
                reason: 'the delivery plan names this story as needing review '
                    'at `guided` or above before it reaches an Early Learner');
          });
        }

        if (story.genre == 'parable' || story.genre == 'poetry') {
          test('reflection stays open rather than closing the passage down', () {
            expect(story.steps.discuss.question.trim().endsWith('?'), isTrue,
                reason: 'parable and poetry packages end in open reflection');
          });
        }
      });
    }
  });

  test('story ids are unique and match their filenames', () {
    final seen = <String>{};
    for (final file in files) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final id = json['id'] as String;
      expect(seen.add(id), isTrue, reason: 'duplicate story id $id');
      expect(file.uri.pathSegments.last, '$id.json',
          reason: 'story id must match its filename');
    }
  });
}
