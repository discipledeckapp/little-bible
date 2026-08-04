// Canonical Bible data for all 66 books.
//
// key          — URL-safe GoRouter path segment (e.g. "genesis", "1-samuel").
// displayName  — Title-case name matching the `book` column in the Drift DB
//                (e.g. "Genesis", "1 Samuel").
// abbr         — 3-letter standard abbreviation for compact UI (eSword style).
// isOT         — true = Old Testament, false = New Testament.
// chapterCount — Canonical chapter count.
// emoji        — Representative emoji for the book.
// description  — Child-friendly one-liner (~8 words).

class BibleBookDef {
  const BibleBookDef({
    required this.key,
    required this.displayName,
    required this.abbr,
    required this.isOT,
    required this.chapterCount,
    required this.emoji,
    required this.description,
  });

  final String key;
  final String displayName;
  final String abbr;
  final bool isOT;
  final int chapterCount;
  final String emoji;
  final String description;
}

// ─── Books with LBV content currently seeded ─────────────────────────────────

const Set<String> kLbvBookKeys = {
  'genesis',
  'psalms',
  'proverbs',
  'matthew',
  'mark',
  'luke',
  'john',
};

bool bookHasLbv(String key) => kLbvBookKeys.contains(key);

// ─── Full 66-book canon in canonical order ────────────────────────────────────

const List<BibleBookDef> kBibleBooks = [
  // ══ Old Testament ═══════════════════════════════════════════════════════════
  BibleBookDef(key: 'genesis',         displayName: 'Genesis',        abbr: 'Gen', isOT: true,  chapterCount: 50,  emoji: '🌍', description: 'God creates the world and makes big promises.'),
  BibleBookDef(key: 'exodus',          displayName: 'Exodus',         abbr: 'Exo', isOT: true,  chapterCount: 40,  emoji: '🌊', description: 'Moses leads God\'s people out of Egypt.'),
  BibleBookDef(key: 'leviticus',       displayName: 'Leviticus',      abbr: 'Lev', isOT: true,  chapterCount: 27,  emoji: '📜', description: 'God\'s rules for worship and holy living.'),
  BibleBookDef(key: 'numbers',         displayName: 'Numbers',        abbr: 'Num', isOT: true,  chapterCount: 36,  emoji: '🔢', description: 'Israel wanders the desert trusting God.'),
  BibleBookDef(key: 'deuteronomy',     displayName: 'Deuteronomy',    abbr: 'Deu', isOT: true,  chapterCount: 34,  emoji: '📣', description: 'Moses reminds Israel to love and obey God.'),
  BibleBookDef(key: 'joshua',          displayName: 'Joshua',         abbr: 'Jos', isOT: true,  chapterCount: 24,  emoji: '⚔️', description: 'Joshua leads Israel into the promised land.'),
  BibleBookDef(key: 'judges',          displayName: 'Judges',         abbr: 'Jdg', isOT: true,  chapterCount: 21,  emoji: '🦁', description: 'Heroes God raised when Israel needed rescue.'),
  BibleBookDef(key: 'ruth',            displayName: 'Ruth',           abbr: 'Rut', isOT: true,  chapterCount: 4,   emoji: '🌾', description: 'A loyal woman who trusted God\'s kindness.'),
  BibleBookDef(key: '1-samuel',        displayName: '1 Samuel',       abbr: '1Sa', isOT: true,  chapterCount: 31,  emoji: '👑', description: 'From Samuel to Saul, Israel\'s first king.'),
  BibleBookDef(key: '2-samuel',        displayName: '2 Samuel',       abbr: '2Sa', isOT: true,  chapterCount: 24,  emoji: '🎯', description: 'King David\'s greatest victories and failures.'),
  BibleBookDef(key: '1-kings',         displayName: '1 Kings',        abbr: '1Ki', isOT: true,  chapterCount: 22,  emoji: '🏛️', description: 'Solomon builds the temple; Israel splits in two.'),
  BibleBookDef(key: '2-kings',         displayName: '2 Kings',        abbr: '2Ki', isOT: true,  chapterCount: 25,  emoji: '🔥', description: 'Elijah, Elisha, and Israel\'s fall from God.'),
  BibleBookDef(key: '1-chronicles',    displayName: '1 Chronicles',   abbr: '1Ch', isOT: true,  chapterCount: 29,  emoji: '📖', description: 'The family history of God\'s chosen people.'),
  BibleBookDef(key: '2-chronicles',    displayName: '2 Chronicles',   abbr: '2Ch', isOT: true,  chapterCount: 36,  emoji: '🏰', description: 'Kings who followed or ignored God\'s ways.'),
  BibleBookDef(key: 'ezra',            displayName: 'Ezra',           abbr: 'Ezr', isOT: true,  chapterCount: 10,  emoji: '🔨', description: 'God\'s people rebuild after exile in Babylon.'),
  BibleBookDef(key: 'nehemiah',        displayName: 'Nehemiah',       abbr: 'Neh', isOT: true,  chapterCount: 13,  emoji: '🧱', description: 'Nehemiah rebuilds Jerusalem\'s walls with courage.'),
  BibleBookDef(key: 'esther',          displayName: 'Esther',         abbr: 'Est', isOT: true,  chapterCount: 10,  emoji: '👸', description: 'A brave queen who saved her whole people.'),
  BibleBookDef(key: 'job',             displayName: 'Job',            abbr: 'Job', isOT: true,  chapterCount: 42,  emoji: '💪', description: 'Job suffers greatly but trusts God throughout.'),
  BibleBookDef(key: 'psalms',          displayName: 'Psalms',         abbr: 'Psa', isOT: true,  chapterCount: 150, emoji: '🎵', description: 'Songs and prayers for every feeling we have.'),
  BibleBookDef(key: 'proverbs',        displayName: 'Proverbs',       abbr: 'Pro', isOT: true,  chapterCount: 31,  emoji: '💡', description: 'God\'s wise words for making good choices.'),
  BibleBookDef(key: 'ecclesiastes',    displayName: 'Ecclesiastes',   abbr: 'Ecc', isOT: true,  chapterCount: 12,  emoji: '🌀', description: 'Life without God is empty; fear Him instead.'),
  BibleBookDef(key: 'song-of-solomon', displayName: 'Song of Solomon', abbr: 'Sng', isOT: true, chapterCount: 8,   emoji: '🌹', description: 'A beautiful poem about love and belonging.'),
  BibleBookDef(key: 'isaiah',          displayName: 'Isaiah',         abbr: 'Isa', isOT: true,  chapterCount: 66,  emoji: '🕊️', description: 'God promises a Saviour who brings true peace.'),
  BibleBookDef(key: 'jeremiah',        displayName: 'Jeremiah',       abbr: 'Jer', isOT: true,  chapterCount: 52,  emoji: '😭', description: 'A prophet who kept speaking for God despite tears.'),
  BibleBookDef(key: 'lamentations',    displayName: 'Lamentations',   abbr: 'Lam', isOT: true,  chapterCount: 5,   emoji: '💔', description: 'Sad songs after Jerusalem fell, yet God is faithful.'),
  BibleBookDef(key: 'ezekiel',         displayName: 'Ezekiel',        abbr: 'Ezk', isOT: true,  chapterCount: 48,  emoji: '⚡', description: 'Strange visions showing God\'s glory and new life.'),
  BibleBookDef(key: 'daniel',          displayName: 'Daniel',         abbr: 'Dan', isOT: true,  chapterCount: 12,  emoji: '🦁', description: 'Daniel stays faithful to God even facing lions.'),
  BibleBookDef(key: 'hosea',           displayName: 'Hosea',          abbr: 'Hos', isOT: true,  chapterCount: 14,  emoji: '❤️', description: 'God\'s love never gives up on His people.'),
  BibleBookDef(key: 'joel',            displayName: 'Joel',           abbr: 'Jol', isOT: true,  chapterCount: 3,   emoji: '🦗', description: 'A locust plague points to God\'s Day of judgment.'),
  BibleBookDef(key: 'amos',            displayName: 'Amos',           abbr: 'Amo', isOT: true,  chapterCount: 9,   emoji: '⚖️', description: 'Treat the poor fairly — God is watching everything.'),
  BibleBookDef(key: 'obadiah',         displayName: 'Obadiah',        abbr: 'Oba', isOT: true,  chapterCount: 1,   emoji: '📯', description: 'The shortest OT book: God judges proud Edom.'),
  BibleBookDef(key: 'jonah',           displayName: 'Jonah',          abbr: 'Jon', isOT: true,  chapterCount: 4,   emoji: '🐋', description: 'A runaway prophet swallowed by a giant fish.'),
  BibleBookDef(key: 'micah',           displayName: 'Micah',          abbr: 'Mic', isOT: true,  chapterCount: 7,   emoji: '🌟', description: 'Do justice, love kindness, walk humbly with God.'),
  BibleBookDef(key: 'nahum',           displayName: 'Nahum',          abbr: 'Nam', isOT: true,  chapterCount: 3,   emoji: '🌪️', description: 'God ends the cruelty of mighty Nineveh forever.'),
  BibleBookDef(key: 'habakkuk',        displayName: 'Habakkuk',       abbr: 'Hab', isOT: true,  chapterCount: 3,   emoji: '🤔', description: 'Why do bad things happen? God\'s answer surprises.'),
  BibleBookDef(key: 'zephaniah',       displayName: 'Zephaniah',      abbr: 'Zep', isOT: true,  chapterCount: 3,   emoji: '🔔', description: 'A warning day of judgment and great future joy.'),
  BibleBookDef(key: 'haggai',          displayName: 'Haggai',         abbr: 'Hag', isOT: true,  chapterCount: 2,   emoji: '🏗️', description: 'Stop ignoring God — rebuild His temple now!'),
  BibleBookDef(key: 'zechariah',       displayName: 'Zechariah',      abbr: 'Zec', isOT: true,  chapterCount: 14,  emoji: '🎺', description: 'Visions pointing to Israel\'s coming King and Saviour.'),
  BibleBookDef(key: 'malachi',         displayName: 'Malachi',        abbr: 'Mal', isOT: true,  chapterCount: 4,   emoji: '✉️', description: "God's final OT message: a messenger is coming."),

  // ══ New Testament ═══════════════════════════════════════════════════════════
  BibleBookDef(key: 'matthew',         displayName: 'Matthew',        abbr: 'Mat', isOT: false, chapterCount: 28,  emoji: '⭐', description: "Jesus' teachings — Sermon on the Mount and miracles."),
  BibleBookDef(key: 'mark',            displayName: 'Mark',           abbr: 'Mrk', isOT: false, chapterCount: 16,  emoji: '⚡', description: 'Jesus heals, teaches, and serves with great power.'),
  BibleBookDef(key: 'luke',            displayName: 'Luke',           abbr: 'Luk', isOT: false, chapterCount: 24,  emoji: '🕊️', description: "Jesus' full story from birth to resurrection."),
  BibleBookDef(key: 'john',            displayName: 'John',           abbr: 'Jhn', isOT: false, chapterCount: 21,  emoji: '❤️', description: "Jesus is God's Son — love, light, and eternal life."),
  BibleBookDef(key: 'acts',            displayName: 'Acts',           abbr: 'Act', isOT: false, chapterCount: 28,  emoji: '🔥', description: 'The Holy Spirit helps the early church spread everywhere.'),
  BibleBookDef(key: 'romans',          displayName: 'Romans',         abbr: 'Rom', isOT: false, chapterCount: 16,  emoji: '✝️', description: "Everyone needs Jesus; His grace saves us all."),
  BibleBookDef(key: '1-corinthians',   displayName: '1 Corinthians',  abbr: '1Co', isOT: false, chapterCount: 16,  emoji: '💌', description: "Love is the greatest gift God gives His people."),
  BibleBookDef(key: '2-corinthians',   displayName: '2 Corinthians',  abbr: '2Co', isOT: false, chapterCount: 13,  emoji: '💪', description: "God's power shows best when we feel very weak."),
  BibleBookDef(key: 'galatians',       displayName: 'Galatians',      abbr: 'Gal', isOT: false, chapterCount: 6,   emoji: '🦅', description: 'We are free in Jesus — not slaves to law.'),
  BibleBookDef(key: 'ephesians',       displayName: 'Ephesians',      abbr: 'Eph', isOT: false, chapterCount: 6,   emoji: '🛡️', description: "Put on God's armour and live as His children."),
  BibleBookDef(key: 'philippians',     displayName: 'Philippians',    abbr: 'Php', isOT: false, chapterCount: 4,   emoji: '😊', description: 'Be joyful always — God is in control of everything.'),
  BibleBookDef(key: 'colossians',      displayName: 'Colossians',     abbr: 'Col', isOT: false, chapterCount: 4,   emoji: '🌱', description: 'Jesus is above everything — keep growing in Him.'),
  BibleBookDef(key: '1-thessalonians', displayName: '1 Thessalonians', abbr: '1Th', isOT: false, chapterCount: 5,  emoji: '🕐', description: "Jesus is coming back — be ready and keep praying."),
  BibleBookDef(key: '2-thessalonians', displayName: '2 Thessalonians', abbr: '2Th', isOT: false, chapterCount: 3,  emoji: '⏳', description: 'Stay faithful while waiting for Jesus to return.'),
  BibleBookDef(key: '1-timothy',       displayName: '1 Timothy',      abbr: '1Ti', isOT: false, chapterCount: 6,   emoji: '📝', description: 'How to lead a church well and live for God.'),
  BibleBookDef(key: '2-timothy',       displayName: '2 Timothy',      abbr: '2Ti', isOT: false, chapterCount: 4,   emoji: '🏃', description: "Stay strong in faith; finish the race for God."),
  BibleBookDef(key: 'titus',           displayName: 'Titus',          abbr: 'Tit', isOT: false, chapterCount: 3,   emoji: '🌴', description: 'Do good works and lead with kindness and truth.'),
  BibleBookDef(key: 'philemon',        displayName: 'Philemon',       abbr: 'Phm', isOT: false, chapterCount: 1,   emoji: '🤝', description: 'Forgive others because Jesus has forgiven you.'),
  BibleBookDef(key: 'hebrews',         displayName: 'Hebrews',        abbr: 'Heb', isOT: false, chapterCount: 13,  emoji: '⚓', description: 'Jesus is better than everything in the Old Testament.'),
  BibleBookDef(key: 'james',           displayName: 'James',          abbr: 'Jas', isOT: false, chapterCount: 5,   emoji: '🌿', description: 'Real faith always shows in how you treat others.'),
  BibleBookDef(key: '1-peter',         displayName: '1 Peter',        abbr: '1Pe', isOT: false, chapterCount: 5,   emoji: '🪨', description: "Stand firm when life is hard; hope in God."),
  BibleBookDef(key: '2-peter',         displayName: '2 Peter',        abbr: '2Pe', isOT: false, chapterCount: 3,   emoji: '⚠️', description: 'Watch out for false teachers; keep growing in truth.'),
  BibleBookDef(key: '1-john',          displayName: '1 John',         abbr: '1Jn', isOT: false, chapterCount: 5,   emoji: '💛', description: 'God is love — love one another and love Him.'),
  BibleBookDef(key: '2-john',          displayName: '2 John',         abbr: '2Jn', isOT: false, chapterCount: 1,   emoji: '💌', description: 'Walk in truth and love, just as God commanded.'),
  BibleBookDef(key: '3-john',          displayName: '3 John',         abbr: '3Jn', isOT: false, chapterCount: 1,   emoji: '📮', description: 'Praise those who help other Christians along the way.'),
  BibleBookDef(key: 'jude',            displayName: 'Jude',           abbr: 'Jud', isOT: false, chapterCount: 1,   emoji: '🛡️', description: "Fight for the faith God has given to you."),
  BibleBookDef(key: 'revelation',      displayName: 'Revelation',     abbr: 'Rev', isOT: false, chapterCount: 22,  emoji: '🌈', description: "Jesus wins in the end — heaven is our home!"),
];

// ─── Helpers ─────────────────────────────────────────────────────────────────

List<BibleBookDef> get kOtBooks => kBibleBooks.where((b) => b.isOT).toList();

List<BibleBookDef> get kNtBooks => kBibleBooks.where((b) => !b.isOT).toList();

/// Returns the [BibleBookDef] for the given URL key (e.g. "genesis"),
/// or null if the key is not in the canon.
BibleBookDef? bookDefByKey(String key) {
  for (final b in kBibleBooks) {
    if (b.key == key) return b;
  }
  return null;
}
