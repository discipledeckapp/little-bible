// ─── MemoryBuilder (FillTheGap source) ───────────────────────────────────────

class MemoryBuilder {
  final String phrase;
  final List<String> phraseWords;
  final String verseRef;
  final String verseText;
  final List<String> verseWords;

  const MemoryBuilder({
    required this.phrase,
    required this.phraseWords,
    required this.verseRef,
    required this.verseText,
    required this.verseWords,
  });

  factory MemoryBuilder.fromJson(Map<String, dynamic> j) => MemoryBuilder(
        phrase: j['phrase'] as String,
        phraseWords: (j['phraseWords'] as List<dynamic>).cast<String>(),
        verseRef: j['verseRef'] as String,
        verseText: j['verseText'] as String,
        verseWords: (j['verseWords'] as List<dynamic>).cast<String>(),
      );
}

// ─── Sequence (TrueOrFalse + Ordering source) ────────────────────────────────

class SequenceItem {
  final String id;
  final String label;
  final String emoji;
  final int order;

  const SequenceItem({
    required this.id,
    required this.label,
    required this.emoji,
    required this.order,
  });

  factory SequenceItem.fromJson(Map<String, dynamic> j) => SequenceItem(
        id: j['id'] as String,
        label: j['label'] as String,
        emoji: (j['emoji'] as String?) ?? '',
        order: j['order'] as int,
      );
}

class ActivitySequence {
  final String prompt;
  final List<SequenceItem> items;

  const ActivitySequence({required this.prompt, required this.items});

  factory ActivitySequence.fromJson(Map<String, dynamic> j) => ActivitySequence(
        prompt: j['prompt'] as String,
        items: (j['items'] as List<dynamic>)
            .map((i) => SequenceItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );

  /// Returns items sorted by their correct order.
  List<SequenceItem> get sorted => [...items]..sort((a, b) => a.order.compareTo(b.order));
}

// ─── Matches ─────────────────────────────────────────────────────────────────

class MatchPair {
  final String leftId;
  final String left;
  final String leftEmoji;
  final String rightId;
  final String right;
  final String rightEmoji;

  const MatchPair({
    required this.leftId,
    required this.left,
    required this.leftEmoji,
    required this.rightId,
    required this.right,
    required this.rightEmoji,
  });

  factory MatchPair.fromJson(Map<String, dynamic> j) => MatchPair(
        leftId: j['leftId'] as String,
        left: j['left'] as String,
        leftEmoji: (j['leftEmoji'] as String?) ?? '',
        rightId: j['rightId'] as String,
        right: j['right'] as String,
        rightEmoji: (j['rightEmoji'] as String?) ?? '',
      );
}

class ActivityMatches {
  final String prompt;
  final List<MatchPair> pairs;
  // Optional: overrides "What did {left} do?" — use {left} as placeholder
  final String? questionTemplate;

  const ActivityMatches({required this.prompt, required this.pairs, this.questionTemplate});

  factory ActivityMatches.fromJson(Map<String, dynamic> j) => ActivityMatches(
        prompt: j['prompt'] as String,
        pairs: (j['pairs'] as List<dynamic>)
            .map((p) => MatchPair.fromJson(p as Map<String, dynamic>))
            .toList(),
        questionTemplate: j['questionTemplate'] as String?,
      );
}

// ─── Application (reflection pick) ───────────────────────────────────────────

class ActivityOption {
  final String id;
  final String label;
  final String emoji;

  const ActivityOption({required this.id, required this.label, required this.emoji});

  factory ActivityOption.fromJson(Map<String, dynamic> j) => ActivityOption(
        id: j['id'] as String,
        label: j['label'] as String,
        emoji: (j['emoji'] as String?) ?? '',
      );
}

class ActivityApplication {
  final String question;
  final List<ActivityOption> options;
  final String followUp;

  const ActivityApplication({
    required this.question,
    required this.options,
    required this.followUp,
  });

  factory ActivityApplication.fromJson(Map<String, dynamic> j) => ActivityApplication(
        question: j['question'] as String,
        options: (j['options'] as List<dynamic>)
            .map((o) => ActivityOption.fromJson(o as Map<String, dynamic>))
            .toList(),
        followUp: (j['followUp'] as String?) ?? '',
      );
}

// ─── Top-level activity ───────────────────────────────────────────────────────

class ActivityModel {
  final String storyId;
  final MemoryBuilder? memoryBuilder;
  final ActivitySequence? sequence;
  final ActivityMatches? matches;
  final ActivityApplication? application;

  const ActivityModel({
    required this.storyId,
    this.memoryBuilder,
    this.sequence,
    this.matches,
    this.application,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> j) => ActivityModel(
        storyId: j['storyId'] as String,
        memoryBuilder: j['memoryBuilder'] != null
            ? MemoryBuilder.fromJson(j['memoryBuilder'] as Map<String, dynamic>)
            : null,
        sequence: j['sequence'] != null
            ? ActivitySequence.fromJson(j['sequence'] as Map<String, dynamic>)
            : null,
        matches: j['matches'] != null
            ? ActivityMatches.fromJson(j['matches'] as Map<String, dynamic>)
            : null,
        application: j['application'] != null
            ? ActivityApplication.fromJson(j['application'] as Map<String, dynamic>)
            : null,
      );
}
