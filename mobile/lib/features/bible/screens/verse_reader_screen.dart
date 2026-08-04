import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/data/bible_canon.dart';
import '../../../core/database/app_database.dart';
import '../../../core/providers/database_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../story/widgets/highlight_text.dart';

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

  // ── TTS ─────────────────────────────────────────────────────────────────────
  // Cached in initState so dispose() can call _tts.stop() without ref.read.
  late TtsService _tts;
  bool _isPlaying = false;
  int? _highlightStart;
  int? _highlightEnd;

  // ───────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _tts = ref.read(ttsServiceProvider);
    _loadData();
  }

  @override
  void dispose() {
    // Direct call — no ref.read, no setState. Avoids "Cannot use ref after
    // widget was disposed" crash.
    _tts.stop();
    super.dispose();
  }

  // ── Derived ─────────────────────────────────────────────────────────────────

  String get _displayBook =>
      bookDefByKey(widget.book)?.displayName ??
      (widget.book.isNotEmpty
          ? widget.book[0].toUpperCase() + widget.book.substring(1)
          : widget.book);

  Verse? get _current =>
      _verses.isNotEmpty && _currentIndex < _verses.length
          ? _verses[_currentIndex]
          : null;

  String get _verseText {
    final v = _current;
    if (v == null) return '';
    return v.littleBible?.isNotEmpty == true
        ? v.littleBible!
        : (v.kjv?.isNotEmpty == true ? v.kjv! : v.body);
  }

  // ── Data loading ─────────────────────────────────────────────────────────────

  Future<void> _loadData() async {
    final db = ref.read(databaseProvider);
    final verses = await db.getChapterVerses(_displayBook, widget.chapter);
    final chapters = await db.getLoadedChapters(_displayBook);
    final chapterData =
        chapters.where((c) => c.chapter == widget.chapter).firstOrNull;

    if (!mounted) return;
    setState(() {
      _verses = verses;
      _chapterData = chapterData;
      _loading = false;
      final idx = verses.indexWhere((v) => v.verse == widget.startVerse);
      _currentIndex = idx >= 0 ? idx : 0;
    });
  }

  // ── TTS ──────────────────────────────────────────────────────────────────────

  Future<void> _toggleAudio() async {
    if (_isPlaying) {
      await _tts.stop();
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _highlightStart = null;
          _highlightEnd = null;
        });
      }
      return;
    }

    final text = _verseText;
    if (text.isEmpty) return;

    setState(() {
      _isPlaying = true;
      _highlightStart = null;
      _highlightEnd = null;
    });

    await _tts.speakWithHighlight(
      text,
      onWord: (_, start, end) {
        if (mounted) {
          setState(() {
            _highlightStart = start;
            _highlightEnd = end;
          });
        }
      },
      onDone: () {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _highlightStart = null;
            _highlightEnd = null;
          });
        }
      },
    );
  }

  void _stopAudio() {
    _tts.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
        _highlightStart = null;
        _highlightEnd = null;
      });
    }
  }

  // ── Verse navigation ──────────────────────────────────────────────────────────

  void _goToPrev() {
    if (_currentIndex <= 0) return;
    _stopAudio();
    setState(() => _currentIndex--);
  }

  void _goToNext() {
    _stopAudio();
    if (_currentIndex < _verses.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _showNextChapterPrompt();
    }
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────────────

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
              style: AppTextStyles.heading
                  .copyWith(color: AppColours.textDark, fontSize: 20),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve finished $_displayBook ${widget.chapter}.',
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                  color: AppColours.textMuted, fontWeight: FontWeight.w400),
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
                      borderRadius: BorderRadius.circular(14)),
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
                      horizontal: 16, vertical: 12),
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
                  const Icon(Icons.people_rounded,
                      color: AppColours.prayerPurple, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'For Parents',
                    style: AppTextStyles.heading
                        .copyWith(color: AppColours.textDark, fontSize: 18),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_verses.isEmpty) {
      return Scaffold(
        backgroundColor: AppColours.cream,
        appBar: AppBar(
          backgroundColor: AppColours.cream,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColours.textDark),
            onPressed: () => context.go('/bible/${widget.book}'),
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

    return Scaffold(
      backgroundColor: AppColours.cream,
      appBar: AppBar(
        backgroundColor: AppColours.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColours.textDark),
          onPressed: () => context.go('/bible/${widget.book}'),
        ),
        title: Text(
          '$_displayBook ${widget.chapter}',
          style: AppTextStyles.heading.copyWith(
              color: AppColours.textDark, fontSize: 18),
        ),
        actions: [
          // ℹ  Child commentary (memory phrase + collapsible tiles)
          IconButton(
            tooltip: 'Notes',
            icon: const Icon(Icons.info_outline_rounded,
                color: AppColours.textMuted),
            onPressed: _showChildCommentarySheet,
          ),
          // 👁  Parent sheet
          IconButton(
            tooltip: 'For parents',
            icon: const Icon(Icons.visibility_rounded,
                color: AppColours.textMuted),
            onPressed: _showParentSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Thin progress bar ─────────────────────────────────────────────
          _ProgressBar(current: _currentIndex + 1, total: total),

          // ── Main verse area with tap-zone navigation ──────────────────────
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              // Tap left/right half to navigate
              onTapUp: (details) {
                final half = MediaQuery.sizeOf(context).width / 2;
                if (details.localPosition.dx < half) {
                  _goToPrev();
                } else {
                  _goToNext();
                }
              },
              // Swipe left/right to navigate
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity ?? 0;
                if (v < -300) _goToNext();
                if (v > 300) _goToPrev();
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // ── Centered verse text ─────────────────────────────────
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Verse text — large and readable
                          HighlightText(
                            text: verseText,
                            highlightStart: _highlightStart,
                            highlightEnd: _highlightEnd,
                            style: AppTextStyles.verseAdapted.copyWith(
                              color: AppColours.textDark,
                              fontSize: 26,
                              height: 1.65,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 18),
                          // Verse reference
                          Text(
                            '$_displayBook ${widget.chapter}:${v.verse}',
                            style: AppTextStyles.label.copyWith(
                              color: AppColours.textMuted,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Left affordance arrow (subtle) ──────────────────────
                  if (_currentIndex > 0)
                    Positioned(
                      left: 6,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Icon(
                          Icons.chevron_left_rounded,
                          color: AppColours.textMuted
                              .withValues(alpha: 0.25),
                          size: 32,
                        ),
                      ),
                    ),

                  // ── Right affordance arrow (subtle) ─────────────────────
                  Positioned(
                    right: 6,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColours.textMuted
                            .withValues(alpha: 0.25),
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Listen button ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: _toggleAudio,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: _isPlaying
                        ? AppColours.lumiGold.withValues(alpha: 0.12)
                        : AppColours.lumiGold,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPlaying
                            ? Icons.stop_rounded
                            : Icons.play_arrow_rounded,
                        color:
                            _isPlaying ? AppColours.lumiGold : Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isPlaying ? 'Stop' : 'Listen',
                        style: AppTextStyles.label.copyWith(
                          color: _isPlaying
                              ? AppColours.lumiGold
                              : Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
          valueColor:
              const AlwaysStoppedAnimation(AppColours.lumiGold),
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
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(widget.icon,
                        style: const TextStyle(fontSize: 15)),
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
