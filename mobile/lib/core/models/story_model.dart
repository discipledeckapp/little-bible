import 'dart:ui';

class StoryVerse {
  final String ref;
  final String kjv;
  final String littleBible;

  const StoryVerse({required this.ref, required this.kjv, required this.littleBible});

  factory StoryVerse.fromJson(Map<String, dynamic> j) => StoryVerse(
        ref: j['ref'] as String,
        kjv: j['kjv'] as String,
        littleBible: (j['little_bible'] as String?) ?? '',
      );
}

class StoryRead {
  final String text;
  final String childText;
  final List<StoryVerse> verses;

  const StoryRead({required this.text, required this.childText, required this.verses});

  factory StoryRead.fromJson(Map<String, dynamic> j) => StoryRead(
        text: j['text'] as String,
        childText: j['childText'] as String,
        verses: (j['verses'] as List<dynamic>)
            .map((v) => StoryVerse.fromJson(v as Map<String, dynamic>))
            .toList(),
      );
}

class StoryDiscuss {
  final String question;
  final String parentGuide;
  final String familyQuestion;

  const StoryDiscuss({required this.question, required this.parentGuide, this.familyQuestion = ''});

  factory StoryDiscuss.fromJson(Map<String, dynamic> j) => StoryDiscuss(
        question: j['question'] as String,
        parentGuide: (j['parentGuide'] as String?) ?? '',
        familyQuestion: (j['familyQuestion'] as String?) ?? '',
      );
}

class StoryPray {
  final String guidedPrayer;
  final String childPrompt;

  const StoryPray({required this.guidedPrayer, required this.childPrompt});

  factory StoryPray.fromJson(Map<String, dynamic> j) => StoryPray(
        guidedPrayer: (j['guidedPrayer'] as String?) ?? '',
        childPrompt: (j['childPrompt'] as String?) ?? '',
      );
}

class StoryRemember {
  final String memoryVerse;
  final String ref;
  final String memoryPhrase;
  final String tip;

  const StoryRemember({
    required this.memoryVerse,
    required this.ref,
    required this.memoryPhrase,
    this.tip = '',
  });

  factory StoryRemember.fromJson(Map<String, dynamic> j) => StoryRemember(
        memoryVerse: j['memoryVerse'] as String,
        ref: j['ref'] as String,
        memoryPhrase: j['memoryPhrase'] as String,
        tip: (j['tip'] as String?) ?? '',
      );
}

class StoryDoToday {
  final String action;
  final String parentNote;

  const StoryDoToday({required this.action, this.parentNote = ''});

  factory StoryDoToday.fromJson(Map<String, dynamic> j) => StoryDoToday(
        action: j['action'] as String,
        parentNote: (j['parentNote'] as String?) ?? '',
      );
}

class StorySteps {
  final StoryRead read;
  final StoryDiscuss discuss;
  final StoryPray pray;
  final StoryRemember remember;
  final StoryDoToday doToday;

  const StorySteps({
    required this.read,
    required this.discuss,
    required this.pray,
    required this.remember,
    required this.doToday,
  });

  factory StorySteps.fromJson(Map<String, dynamic> j) => StorySteps(
        read: StoryRead.fromJson(j['read'] as Map<String, dynamic>),
        discuss: StoryDiscuss.fromJson(j['discuss'] as Map<String, dynamic>),
        pray: StoryPray.fromJson(j['pray'] as Map<String, dynamic>),
        remember: StoryRemember.fromJson(j['remember'] as Map<String, dynamic>),
        doToday: StoryDoToday.fromJson(j['doToday'] as Map<String, dynamic>),
      );
}

class StoryModel {
  final String id;
  final String title;
  final String subtitle;
  final String collection;
  final String mainTruth;
  final String bibleRef;
  final String coverEmoji;
  final Color coverColor;
  final StorySteps steps;
  final String sensitivityTier;

  const StoryModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.collection,
    required this.mainTruth,
    required this.bibleRef,
    required this.coverEmoji,
    required this.coverColor,
    required this.steps,
    this.sensitivityTier = 'general',
  });

  factory StoryModel.fromJson(Map<String, dynamic> j) {
    final hex = (j['coverColor'] as String).replaceAll('#', '');
    final color = Color(int.parse('FF$hex', radix: 16));
    return StoryModel(
      id: j['id'] as String,
      title: j['title'] as String,
      subtitle: (j['subtitle'] as String?) ?? '',
      collection: (j['collection'] as String?) ?? '',
      mainTruth: (j['mainTruth'] as String?) ?? '',
      bibleRef: (j['bibleRef'] as String?) ?? '',
      coverEmoji: (j['coverEmoji'] as String?) ?? '📖',
      coverColor: color,
      steps: StorySteps.fromJson(j['steps'] as Map<String, dynamic>),
      sensitivityTier: (j['sensitivityTier'] as String?) ?? 'general',
    );
  }

  /// Splits story text into scenes (paragraphs) appropriate for the age band.
  List<String> scenes(String ageBand) {
    final raw = steps.read.childText.trim().isNotEmpty ? steps.read.childText : steps.read.text;
    return raw.split('\n\n').where((s) => s.trim().isNotEmpty).toList();
  }
}
