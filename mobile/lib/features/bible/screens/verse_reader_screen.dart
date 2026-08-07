import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/bible_canon.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';

class VerseReaderScreen extends ConsumerStatefulWidget {
  const VerseReaderScreen({
    super.key,
    required this.book,
    required this.chapter,
    this.startVerse = 1,
  });

  final String book;
  final int chapter;
  final int startVerse;

  @override
  ConsumerState<VerseReaderScreen> createState() => _VerseReaderScreenState();
}

class _VerseReaderScreenState extends ConsumerState<VerseReaderScreen> {
  // ── Data ────────────────────────────────────────────────────────────────────
  List<Verse> _verses = [];
  BibleChapter? _chapterData;
  bool _loading = true;

  // ── Navigation ──────────────────────────────────────────────────────────────
  late int _currentIndex;

  // ── Version toggle ───────────────────────────────────────────────────────────
  bool _showKjv = false;

  // ── Audio (Edge TTS remote MP3 + device TTS fallback) ───────────────────────
  late TtsService _tts;
  bool _isPlaying = false;
  bool _isAudioLoading = false;

  // ───────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _tts = ref.read(ttsServiceProvider);
    _loadData();
  }

  @override
  void didUpdateWidget(VerseReaderScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book != widget.book || oldWidget.chapter != widget.chapter) {
      _stopAudio();
      setState(() {
        _loading = true;
        _verses = [];
        _chapterData = null;
        _currentIndex = 0;
        _showKjv = false;
      });
      _loadData();
    }
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  // ── Audio URL — version-aware ─────────────────────────────────────────────

  // ── Derived ─────────────────────────────────────────────────────────────────

  String get _displayBook =>
      bookDefByKey(widget.book)?.displayName ??
      (widget.book.isNotEmpty
          ? widget.book[0].toUpperCase() + widget.book.substring(1)
          : widget.book);

  Verse? get _current => _verses.isNotEmpty && _currentIndex < _verses.length
      ? _verses[_currentIndex]
      : null;

  String get _verseText {
    final v = _current;
    if (v == null) return '';
    final hasLbv = v.littleBible?.isNotEmpty == true;
    final hasKjv = v.kjv?.isNotEmpty == true;
    if (_showKjv && hasKjv) return v.kjv!;
    if (hasLbv) return v.littleBible!;
    if (hasKjv) return v.kjv!;
    return v.body;
  }

  // ── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);
    var verses = await db.getChapterVerses(_displayBook, widget.chapter);

    // If the DB has no verses yet (seeding still in progress or never ran),
    // fall back to reading directly from the bundled JSON asset. This ensures
    // KJV is always available immediately regardless of seeding state.
    if (verses.isEmpty) {
      verses = await _loadVersesFromAsset();
    }

    final chapters = await db.getLoadedChapters(_displayBook);
    final chapterData = chapters
        .where((c) => c.chapter == widget.chapter)
        .firstOrNull;

    if (!mounted) return;
    setState(() {
      _verses = verses;
      _chapterData = chapterData;
      _loading = false;
      final idx = verses.indexWhere((v) => v.verse == widget.startVerse);
      _currentIndex = idx >= 0 ? idx : 0;
    });
  }

  /// Loads verses directly from the bundled JSON asset.
  /// Used when the DB hasn't been seeded yet for this chapter.
  Future<List<Verse>> _loadVersesFromAsset() async {
    // Use the book key as-is from the route — it matches the directory name.
    final bookKey = widget.book.toLowerCase();
    final chPadded = widget.chapter.toString().padLeft(2, '0');
    final assetPath =
        'assets/bible/en/$bookKey/${bookKey}_chapter_$chPadded.json';

    final String raw;
    try {
      raw = await rootBundle.loadString(assetPath);
    } catch (_) {
      // Asset not found — the file may genuinely not exist for this book/chapter.
      return [];
    }

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final bookName = map['book'] as String;
      final chapterNum = map['chapter'] as int;
      final rawVerses = map['verses'] as List<dynamic>;
      return rawVerses.map((v) {
        final vMap = v as Map<String, dynamic>;
        final kjvText = (vMap['kjv'] as String?) ?? '';
        final lbvText = vMap['little_bible'] as String?;
        return Verse(
          id: 0,
          book: bookName,
          chapter: chapterNum,
          verse: vMap['verse'] as int,
          body: lbvText ?? kjvText,
          source: lbvText != null ? 'little-bible' : 'kjv',
          isAdapted: lbvText != null,
          kjv: kjvText.isEmpty ? null : kjvText,
          littleBible: (lbvText == null || lbvText.isEmpty) ? null : lbvText,
          littleReaderAdaptation: vMap['little_reader_adaptation'] as String?,
          meaning: vMap['meaning'] as String?,
          memoryPhrase: vMap['memory_phrase'] as String?,
          prayer: vMap['prayer'] as String?,
          discussionQuestion: vMap['discussion_question'] as String?,
          familyDiscussion: vMap['family_discussion'] as String?,
          doItToday: vMap['do_it_today'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Audio (Edge TTS via remote MP3) ─────────────────────────────────────────

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _tts.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isAudioLoading = false;
        });
      }
      return;
    }

    if (_current == null || _verseText.isEmpty) return;
    setState(() {
      _isAudioLoading = true;
      _isPlaying = true;
    });

    try {
      await _tts.speak(
        _verseText,
        onDone: () {
          if (mounted) {
            setState(() {
              _isPlaying = false;
              _isAudioLoading = false;
            });
          }
        },
      );
      if (mounted) {
        setState(() {
          _isAudioLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isAudioLoading = false;
        });
      }
    }
  }

  Future<void> _stopAudio() async {
    await _tts.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _isAudioLoading = false;
      });
    }
  }

  // ── Verse navigation ──────────────────────────────────────────────────────────

  void _goToPrev() {
    if (_currentIndex <= 0) return;
    _stopAudio().then((_) {
      if (mounted) {
        setState(() {
          _currentIndex--;
          _showKjv = false;
        });
      }
    });
  }

  void _goToNext() {
    _stopAudio().then((_) {
      if (!mounted) return;
      if (_currentIndex < _verses.length - 1) {
        setState(() {
          _currentIndex++;
          _showKjv = false;
        });
      } else {
        _showNextChapterPrompt();
      }
    });
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────────────

  void _showNavPicker() {
    _stopAudio();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BibleNavSheet(
        currentBook: widget.book,
        currentChapter: widget.chapter,
        onSelect: (bookKey, chapter) {
          context.go('/bible/$bookKey/$chapter');
        },
      ),
    );
  }

  void _showNextChapterPrompt() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColours.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              'Chapter complete!',
              style: AppTextStyles.heading.copyWith(
                color: AppColours.textDark,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve finished $_displayBook ${widget.chapter}.',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                color: AppColours.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColours.lumiGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/bible/${widget.book}');
                },
                child: const Text('Choose another chapter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Child-accessible commentary sheet: memory phrase + collapsible tiles.
  void _showChildCommentarySheet() {
    final v = _current;
    if (v == null) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColours.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColours.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Verse reference label
              Text(
                '$_displayBook ${widget.chapter}:${v.verse}',
                style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),

              // Memory phrase
              if ((v.memoryPhrase ?? '').isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColours.lumiGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColours.lumiGold.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          v.memoryPhrase!,
                          style: AppTextStyles.label.copyWith(
                            color: AppColours.deepEarth,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Commentary tiles
              if ((v.meaning ?? '').isNotEmpty)
                _CollapsibleTile(
                  icon: '📖',
                  label: 'What this means',
                  content: v.meaning!,
                ),
              if ((v.prayer ?? '').isNotEmpty)
                _CollapsibleTile(
                  icon: '🙏',
                  label: 'Prayer',
                  content: v.prayer!,
                  accentColor: AppColours.prayerPurple,
                ),
              if ((v.discussionQuestion ?? '').isNotEmpty)
                _CollapsibleTile(
                  icon: '❓',
                  label: 'Talk about it',
                  content: v.discussionQuestion!,
                  accentColor: AppColours.sky,
                ),
              if ((v.doItToday ?? '').isNotEmpty)
                _CollapsibleTile(
                  icon: '📌',
                  label: 'Try today',
                  content: v.doItToday!,
                  accentColor: AppColours.earth,
                ),

              if ((v.memoryPhrase ?? '').isEmpty &&
                  (v.meaning ?? '').isEmpty &&
                  (v.prayer ?? '').isEmpty &&
                  (v.discussionQuestion ?? '').isEmpty &&
                  (v.doItToday ?? '').isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'No extra notes for this verse.',
                      style: AppTextStyles.label.copyWith(
                        color: AppColours.textMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Parent-facing sheet: parent guide + family discussion.
  void _showParentSheet() {
    final ch = _chapterData;
    if (ch == null) return;

    // Find the first verse with family discussion content
    final verseWithFd = _verses
        .where((v) => (v.familyDiscussion ?? '').isNotEmpty)
        .firstOrNull;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColours.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColours.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.people_rounded,
                    color: AppColours.prayerPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'For Parents',
                    style: AppTextStyles.heading.copyWith(
                      color: AppColours.textDark,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if ((ch.parentGuide ?? '').isNotEmpty) ...[
                _SectionLabel('Parent guide'),
                const SizedBox(height: 6),
                Text(
                  ch.parentGuide!,
                  style: AppTextStyles.label.copyWith(
                    color: AppColours.textDark,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (verseWithFd != null) ...[
                _SectionLabel('Family discussion'),
                const SizedBox(height: 6),
                Text(
                  verseWithFd.familyDiscussion!,
                  style: AppTextStyles.label.copyWith(
                    color: AppColours.textDark,
                    fontWeight: FontWeight.w400,
                    height: 1.7,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_verses.isEmpty) {
      return Scaffold(
        backgroundColor: AppColours.cream,
        appBar: AppBar(
          backgroundColor: AppColours.cream,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: AppColours.textDark,
            ),
            onPressed: () =>
              context.go('/bible/${widget.book}/${widget.chapter}'),
          ),
        ),
        body: Center(
          child: Text(
            'No verses found for $_displayBook ${widget.chapter}.',
            style: AppTextStyles.label.copyWith(color: AppColours.textMuted),
          ),
        ),
      );
    }

    final v = _current!;
    final verseText = _verseText;
    final total = _verses.length;
    final hasLbv = v.littleBible?.isNotEmpty == true;
    final hasKjv = v.kjv?.isNotEmpty == true;
    final showingLbv = hasLbv && !_showKjv;
    final versionLabel = showingLbv ? 'LBV' : (hasKjv ? 'KJV' : '');
    final versionColor = showingLbv
        ? AppColours.lumiGold
        : AppColours.textMuted;
    final isFirst = _currentIndex == 0;
    final isLast = _currentIndex == _verses.length - 1;

    return Scaffold(
      backgroundColor: AppColours.cream,
      appBar: AppBar(
        backgroundColor: AppColours.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColours.textDark,
          ),
          onPressed: () =>
              context.go('/bible/${widget.book}/${widget.chapter}'),
        ),
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _showNavPicker,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_displayBook ${widget.chapter}',
                style: AppTextStyles.heading.copyWith(
                  color: AppColours.textDark,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.expand_more_rounded,
                color: AppColours.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
        actions: [
          // LBV ↔ KJV toggle — only shown when current verse has both versions
          if (_current != null && _current!.littleBible?.isNotEmpty == true)
            GestureDetector(
              onTap: () {
                _stopAudio();
                setState(() => _showKjv = !_showKjv);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: _showKjv
                      ? AppColours.textMuted.withValues(alpha: 0.12)
                      : AppColours.lumiGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _showKjv
                        ? AppColours.textMuted.withValues(alpha: 0.4)
                        : AppColours.lumiGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  _showKjv ? 'KJV' : 'LBV',
                  style: AppTextStyles.label.copyWith(
                    color: _showKjv
                        ? AppColours.textMuted
                        : AppColours.lumiGold,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Notes',
            icon: const Icon(
              Icons.info_outline_rounded,
              color: AppColours.textMuted,
            ),
            onPressed: _showChildCommentarySheet,
          ),
          IconButton(
            tooltip: 'For parents',
            icon: const Icon(
              Icons.visibility_rounded,
              color: AppColours.textMuted,
            ),
            onPressed: _showParentSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Progress bar ──────────────────────────────────────────────────
          _ProgressBar(current: _currentIndex + 1, total: total),

          // ── Verse counter + version badge ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Verse ${_currentIndex + 1} of $total',
                  style: AppTextStyles.label.copyWith(
                    color: AppColours.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (versionLabel.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: versionColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: versionColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      versionLabel,
                      style: AppTextStyles.label.copyWith(
                        color: versionColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Main verse area (swipe to navigate) ───────────────────────────
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity < -300) _goToNext();
                if (velocity > 300) _goToPrev();
              },
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        verseText,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.verseAdapted.copyWith(
                          color: AppColours.textDark,
                          fontSize: 26,
                          height: 1.7,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '$_displayBook ${widget.chapter}:${v.verse}',
                        style: AppTextStyles.label.copyWith(
                          color: AppColours.textMuted,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Bottom navigation bar ─────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  // ◀ Previous
                  Expanded(
                    child: _NavButton(
                      icon: Icons.arrow_back_ios_rounded,
                      label: 'Prev',
                      enabled: !isFirst,
                      onTap: _goToPrev,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // ▶ Listen / ■ Stop
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _toggleAudio,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: _isPlaying
                              ? AppColours.lumiGold.withValues(alpha: 0.12)
                              : AppColours.lumiGold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isAudioLoading)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            else
                              Icon(
                                _isPlaying
                                    ? Icons.stop_rounded
                                    : Icons.play_arrow_rounded,
                                color: _isPlaying
                                    ? AppColours.lumiGold
                                    : Colors.white,
                                size: 26,
                              ),
                            const SizedBox(width: 6),
                            Text(
                              _isAudioLoading
                                  ? 'Loading…'
                                  : (_isPlaying ? 'Stop' : 'Listen'),
                              style: AppTextStyles.label.copyWith(
                                color: _isPlaying
                                    ? AppColours.lumiGold
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Next ▶
                  Expanded(
                    child: _NavButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      label: isLast ? 'Done' : 'Next',
                      iconAfter: true,
                      onTap: _goToNext,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Nav button ───────────────────────────────────────────────────────────────

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.iconAfter = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool iconAfter;

  @override
  Widget build(BuildContext context) {
    final color = enabled
        ? AppColours.textDark
        : AppColours.textMuted.withValues(alpha: 0.35);
    final bg = enabled
        ? AppColours.parchment
        : AppColours.parchment.withValues(alpha: 0.5);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!iconAfter) ...[
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyles.label.copyWith(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (iconAfter) ...[
              const SizedBox(width: 4),
              Icon(icon, color: color, size: 16),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Progress bar ──────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total > 0 ? current / total : 0.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: LinearProgressIndicator(
          value: fraction,
          backgroundColor: AppColours.parchment,
          valueColor: const AlwaysStoppedAnimation(AppColours.lumiGold),
          minHeight: 4,
        ),
      ),
    );
  }
}

// ─── Collapsible commentary tile ──────────────────────────────────────────────

class _CollapsibleTile extends StatefulWidget {
  const _CollapsibleTile({
    required this.icon,
    required this.label,
    required this.content,
    this.accentColor = AppColours.lumiGold,
  });

  final String icon;
  final String label;
  final String content;
  final Color accentColor;

  @override
  State<_CollapsibleTile> createState() => _CollapsibleTileState();
}

class _CollapsibleTileState extends State<_CollapsibleTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColours.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _expanded
              ? widget.accentColor.withValues(alpha: 0.35)
              : AppColours.textMuted.withValues(alpha: 0.15),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.icon, style: const TextStyle(fontSize: 15)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.label,
                        style: AppTextStyles.label.copyWith(
                          color: AppColours.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColours.textMuted,
                      size: 20,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 10),
                  Text(
                    widget.content,
                    style: AppTextStyles.label.copyWith(
                      color: AppColours.textDark,
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: 1.65,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section label (used in parent sheet) ─────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: AppTextStyles.label.copyWith(
        color: AppColours.textMuted,
        fontSize: 10,
        letterSpacing: 1.5,
      ),
    );
  }
}

// ─── Bible navigation picker (book → chapter, 2 taps) ────────────────────────

class _BibleNavSheet extends StatefulWidget {
  const _BibleNavSheet({
    required this.currentBook,
    required this.currentChapter,
    required this.onSelect,
  });

  final String currentBook;
  final int currentChapter;
  final void Function(String bookKey, int chapter) onSelect;

  @override
  State<_BibleNavSheet> createState() => _BibleNavSheetState();
}

class _BibleNavSheetState extends State<_BibleNavSheet> {
  BibleBookDef? _selectedBook;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColours.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColours.textMuted.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  if (_selectedBook != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedBook = null),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Icon(
                          Icons.arrow_back_ios_rounded,
                          size: 18,
                          color: AppColours.textDark,
                        ),
                      ),
                    ),
                  Text(
                    _selectedBook == null
                        ? 'Choose a book'
                        : _selectedBook!.displayName,
                    style: AppTextStyles.heading.copyWith(
                      color: AppColours.textDark,
                      fontSize: 18,
                    ),
                  ),
                  if (_selectedBook != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      _selectedBook!.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ],
              ),
            ),

            const Divider(height: 1),

            // Content
            Expanded(
              child: _selectedBook == null
                  ? _BookList(
                      currentBookKey: widget.currentBook,
                      onBookTap: (book) => setState(() => _selectedBook = book),
                      scrollController: controller,
                    )
                  : _ChapterGrid(
                      book: _selectedBook!,
                      currentChapter: _selectedBook!.key == widget.currentBook
                          ? widget.currentChapter
                          : null,
                      onChapterTap: (ch) {
                        Navigator.of(context).pop();
                        widget.onSelect(_selectedBook!.key, ch);
                      },
                      scrollController: controller,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Book grid (all 66 books in one compact view) ─────────────────────────────

class _BookList extends StatelessWidget {
  const _BookList({
    required this.currentBookKey,
    required this.onBookTap,
    required this.scrollController,
  });

  final String currentBookKey;
  final void Function(BibleBookDef) onBookTap;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final ot = kBibleBooks.where((b) => b.isOT).toList();
    final nt = kBibleBooks.where((b) => !b.isOT).toList();

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
          sliver: SliverToBoxAdapter(
            child: _BookSectionHeader('Old Testament'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          sliver: _BookGrid(
            books: ot,
            currentBookKey: currentBookKey,
            onBookTap: onBookTap,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          sliver: SliverToBoxAdapter(
            child: _BookSectionHeader('New Testament'),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          sliver: _BookGrid(
            books: nt,
            currentBookKey: currentBookKey,
            onBookTap: onBookTap,
          ),
        ),
      ],
    );
  }
}

class _BookGrid extends StatelessWidget {
  const _BookGrid({
    required this.books,
    required this.currentBookKey,
    required this.onBookTap,
  });

  final List<BibleBookDef> books;
  final String currentBookKey;
  final void Function(BibleBookDef) onBookTap;

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1.1,
      ),
      delegate: SliverChildBuilderDelegate((_, i) {
        final book = books[i];
        final isCurrent = book.key == currentBookKey;
        return GestureDetector(
          onTap: () => onBookTap(book),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            decoration: BoxDecoration(
              color: isCurrent ? AppColours.lumiGold : AppColours.parchment,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(book.emoji, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 2),
                Text(
                  book.abbr,
                  style: AppTextStyles.label.copyWith(
                    color: isCurrent ? Colors.white : AppColours.textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }, childCount: books.length),
    );
  }
}

class _BookSectionHeader extends StatelessWidget {
  const _BookSectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.label.copyWith(
          color: AppColours.textMuted,
          fontSize: 10,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── Chapter grid ─────────────────────────────────────────────────────────────

class _ChapterGrid extends StatelessWidget {
  const _ChapterGrid({
    required this.book,
    required this.currentChapter,
    required this.onChapterTap,
    required this.scrollController,
  });

  final BibleBookDef book;
  final int? currentChapter;
  final void Function(int) onChapterTap;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: book.chapterCount,
      itemBuilder: (_, i) {
        final ch = i + 1;
        final isCurrent = ch == currentChapter;
        return GestureDetector(
          onTap: () => onChapterTap(ch),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: isCurrent ? AppColours.lumiGold : AppColours.parchment,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              '$ch',
              style: AppTextStyles.label.copyWith(
                color: isCurrent ? Colors.white : AppColours.textDark,
                fontSize: 15,
                fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}
