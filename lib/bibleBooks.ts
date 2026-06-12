export type BookStatus = 'available' | 'in-progress' | 'coming-soon';
export type Testament = 'OT' | 'NT';

export interface BibleBook {
  name: string;
  slug: string;
  abbrev: string;
  testament: Testament;
  group: string;
  groupOrder: number;
  totalChapters: number;
  tagline: string;
  emoji: string;
  accentColor: string;
  status: BookStatus;
}

export const OT_GROUPS = ['The Law', 'History', 'Wisdom & Poetry', 'Major Prophets', 'Minor Prophets'] as const;
export const NT_GROUPS = ['Gospels', 'The Early Church', "Paul's Letters", 'General Letters', 'Prophecy'] as const;

export const BIBLE_BOOKS: BibleBook[] = [
  // ── THE LAW ───────────────────────────────────────────────────────────────
  { name: 'Genesis',       slug: 'genesis',          abbrev: 'Gen', testament: 'OT', group: 'The Law',          groupOrder: 1,  totalChapters: 50,  tagline: 'In the beginning, God made everything',          emoji: '🌍', accentColor: 'amber',   status: 'in-progress' },
  { name: 'Exodus',        slug: 'exodus',           abbrev: 'Exo', testament: 'OT', group: 'The Law',          groupOrder: 2,  totalChapters: 40,  tagline: 'God rescues His people from slavery',            emoji: '🌊', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Leviticus',     slug: 'leviticus',        abbrev: 'Lev', testament: 'OT', group: 'The Law',          groupOrder: 3,  totalChapters: 27,  tagline: 'God shows Israel how to worship Him',            emoji: '🕊️', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Numbers',       slug: 'numbers',          abbrev: 'Num', testament: 'OT', group: 'The Law',          groupOrder: 4,  totalChapters: 36,  tagline: 'God travels with His people in the wilderness',  emoji: '🏕️', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Deuteronomy',   slug: 'deuteronomy',      abbrev: 'Deu', testament: 'OT', group: 'The Law',          groupOrder: 5,  totalChapters: 34,  tagline: 'Remember God and love Him with all your heart',  emoji: '📜', accentColor: 'amber',   status: 'coming-soon' },
  // ── HISTORY ───────────────────────────────────────────────────────────────
  { name: 'Joshua',        slug: 'joshua',           abbrev: 'Jos', testament: 'OT', group: 'History',          groupOrder: 1,  totalChapters: 24,  tagline: 'God leads His people into the promised land',   emoji: '🏔️', accentColor: 'green',   status: 'coming-soon' },
  { name: 'Judges',        slug: 'judges',           abbrev: 'Jdg', testament: 'OT', group: 'History',          groupOrder: 2,  totalChapters: 21,  tagline: 'God saves His people again and again',          emoji: '⚔️', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Ruth',          slug: 'ruth',             abbrev: 'Rut', testament: 'OT', group: 'History',          groupOrder: 3,  totalChapters: 4,   tagline: 'A beautiful story of love and loyalty',         emoji: '🌾', accentColor: 'amber',   status: 'in-progress' },
  { name: '1 Samuel',      slug: '1-samuel',         abbrev: '1Sa', testament: 'OT', group: 'History',          groupOrder: 4,  totalChapters: 31,  tagline: "God chooses a shepherd boy to be king",         emoji: '👑', accentColor: 'amber',   status: 'coming-soon' },
  { name: '2 Samuel',      slug: '2-samuel',         abbrev: '2Sa', testament: 'OT', group: 'History',          groupOrder: 5,  totalChapters: 24,  tagline: 'David becomes king and follows God',           emoji: '👑', accentColor: 'amber',   status: 'coming-soon' },
  { name: '1 Kings',       slug: '1-kings',          abbrev: '1Ki', testament: 'OT', group: 'History',          groupOrder: 6,  totalChapters: 22,  tagline: "Solomon builds God's temple",                  emoji: '🏛️', accentColor: 'amber',   status: 'coming-soon' },
  { name: '2 Kings',       slug: '2-kings',          abbrev: '2Ki', testament: 'OT', group: 'History',          groupOrder: 7,  totalChapters: 25,  tagline: "God's people forget Him and are carried away",  emoji: '🌧️', accentColor: 'stone',   status: 'coming-soon' },
  { name: '1 Chronicles',  slug: '1-chronicles',     abbrev: '1Ch', testament: 'OT', group: 'History',          groupOrder: 8,  totalChapters: 29,  tagline: "The history of God's people and King David",   emoji: '📖', accentColor: 'stone',   status: 'coming-soon' },
  { name: '2 Chronicles',  slug: '2-chronicles',     abbrev: '2Ch', testament: 'OT', group: 'History',          groupOrder: 9,  totalChapters: 36,  tagline: "The story of Solomon and the kings after him",  emoji: '📖', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Ezra',          slug: 'ezra',             abbrev: 'Ezr', testament: 'OT', group: 'History',          groupOrder: 10, totalChapters: 10,  tagline: "God's people return home from captivity",      emoji: '🏠', accentColor: 'green',   status: 'coming-soon' },
  { name: 'Nehemiah',      slug: 'nehemiah',         abbrev: 'Neh', testament: 'OT', group: 'History',          groupOrder: 11, totalChapters: 13,  tagline: 'Rebuilding the walls and trusting God',        emoji: '🧱', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Esther',        slug: 'esther',           abbrev: 'Est', testament: 'OT', group: 'History',          groupOrder: 12, totalChapters: 10,  tagline: 'A brave girl who trusted God',                 emoji: '👸', accentColor: 'rose',    status: 'in-progress' },
  // ── WISDOM & POETRY ───────────────────────────────────────────────────────
  { name: 'Job',           slug: 'job',              abbrev: 'Job', testament: 'OT', group: 'Wisdom & Poetry',  groupOrder: 1,  totalChapters: 42,  tagline: 'Why do hard things happen? God knows.',        emoji: '☁️', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Psalms',        slug: 'psalms',           abbrev: 'Psa', testament: 'OT', group: 'Wisdom & Poetry',  groupOrder: 2,  totalChapters: 150, tagline: 'Songs and prayers straight to God',           emoji: '🎵', accentColor: 'blue',    status: 'in-progress' },
  { name: 'Proverbs',      slug: 'proverbs',         abbrev: 'Pro', testament: 'OT', group: 'Wisdom & Poetry',  groupOrder: 3,  totalChapters: 31,  tagline: "God's wisdom for every single day",           emoji: '✨', accentColor: 'amber',   status: 'available'   },
  { name: 'Ecclesiastes',  slug: 'ecclesiastes',     abbrev: 'Ecc', testament: 'OT', group: 'Wisdom & Poetry',  groupOrder: 4,  totalChapters: 12,  tagline: 'What truly matters in this life',              emoji: '🌬️', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Song of Solomon', slug: 'song-of-solomon', abbrev: 'SoS', testament: 'OT', group: 'Wisdom & Poetry', groupOrder: 5, totalChapters: 8,   tagline: 'A beautiful poem about love',                 emoji: '🌹', accentColor: 'rose',    status: 'coming-soon' },
  // ── MAJOR PROPHETS ────────────────────────────────────────────────────────
  { name: 'Isaiah',        slug: 'isaiah',           abbrev: 'Isa', testament: 'OT', group: 'Major Prophets',   groupOrder: 1,  totalChapters: 66,  tagline: 'God promises a Saviour who is coming',        emoji: '🌟', accentColor: 'blue',    status: 'in-progress' },
  { name: 'Jeremiah',      slug: 'jeremiah',         abbrev: 'Jer', testament: 'OT', group: 'Major Prophets',   groupOrder: 2,  totalChapters: 52,  tagline: "God's message to a people who forgot Him",    emoji: '💧', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Lamentations',  slug: 'lamentations',     abbrev: 'Lam', testament: 'OT', group: 'Major Prophets',   groupOrder: 3,  totalChapters: 5,   tagline: 'A prayer of sadness — and hope',              emoji: '🕯️', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Ezekiel',       slug: 'ezekiel',          abbrev: 'Eze', testament: 'OT', group: 'Major Prophets',   groupOrder: 4,  totalChapters: 48,  tagline: "God shows His glory and promises new life",   emoji: '🌊', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Daniel',        slug: 'daniel',           abbrev: 'Dan', testament: 'OT', group: 'Major Prophets',   groupOrder: 5,  totalChapters: 12,  tagline: 'Daniel trusts God even in danger',            emoji: '🦁', accentColor: 'amber',   status: 'in-progress' },
  // ── MINOR PROPHETS ────────────────────────────────────────────────────────
  { name: 'Hosea',         slug: 'hosea',            abbrev: 'Hos', testament: 'OT', group: 'Minor Prophets',   groupOrder: 1,  totalChapters: 14,  tagline: 'God loves us even when we wander',            emoji: '❤️', accentColor: 'rose',    status: 'coming-soon' },
  { name: 'Joel',          slug: 'joel',             abbrev: 'Joe', testament: 'OT', group: 'Minor Prophets',   groupOrder: 2,  totalChapters: 3,   tagline: 'God promises to pour out His Spirit',         emoji: '🌊', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Amos',          slug: 'amos',             abbrev: 'Amo', testament: 'OT', group: 'Minor Prophets',   groupOrder: 3,  totalChapters: 9,   tagline: 'God cares about fairness and justice',        emoji: '⚖️', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Obadiah',       slug: 'obadiah',          abbrev: 'Oba', testament: 'OT', group: 'Minor Prophets',   groupOrder: 4,  totalChapters: 1,   tagline: 'God sees everything that happens',           emoji: '👁️', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Jonah',         slug: 'jonah',            abbrev: 'Jon', testament: 'OT', group: 'Minor Prophets',   groupOrder: 5,  totalChapters: 4,   tagline: 'Running from God — and coming back',          emoji: '🐳', accentColor: 'blue',    status: 'in-progress' },
  { name: 'Micah',         slug: 'micah',            abbrev: 'Mic', testament: 'OT', group: 'Minor Prophets',   groupOrder: 6,  totalChapters: 7,   tagline: 'Act justly, love kindness, walk with God',   emoji: '🌿', accentColor: 'green',   status: 'coming-soon' },
  { name: 'Nahum',         slug: 'nahum',            abbrev: 'Nah', testament: 'OT', group: 'Minor Prophets',   groupOrder: 7,  totalChapters: 3,   tagline: 'God is powerful and protects His people',    emoji: '⚡', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Habakkuk',      slug: 'habakkuk',         abbrev: 'Hab', testament: 'OT', group: 'Minor Prophets',   groupOrder: 8,  totalChapters: 3,   tagline: 'Trusting God when life feels hard',          emoji: '🌅', accentColor: 'amber',   status: 'coming-soon' },
  { name: 'Zephaniah',     slug: 'zephaniah',        abbrev: 'Zep', testament: 'OT', group: 'Minor Prophets',   groupOrder: 9,  totalChapters: 3,   tagline: 'God saves and rejoices over His people',     emoji: '🎶', accentColor: 'amber',   status: 'coming-soon' },
  { name: 'Haggai',        slug: 'haggai',           abbrev: 'Hag', testament: 'OT', group: 'Minor Prophets',   groupOrder: 10, totalChapters: 2,   tagline: "Put God's house first",                      emoji: '🏠', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Zechariah',     slug: 'zechariah',        abbrev: 'Zec', testament: 'OT', group: 'Minor Prophets',   groupOrder: 11, totalChapters: 14,  tagline: "Visions of God's kingdom coming",            emoji: '🌟', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Malachi',       slug: 'malachi',          abbrev: 'Mal', testament: 'OT', group: 'Minor Prophets',   groupOrder: 12, totalChapters: 4,   tagline: 'The last prophet before Jesus arrives',      emoji: '🕊️', accentColor: 'amber',   status: 'coming-soon' },
  // ── GOSPELS ───────────────────────────────────────────────────────────────
  { name: 'Matthew',       slug: 'matthew',          abbrev: 'Mat', testament: 'NT', group: 'Gospels',          groupOrder: 1,  totalChapters: 28,  tagline: 'Jesus is the promised King',                  emoji: '👑', accentColor: 'emerald', status: 'in-progress' },
  { name: 'Mark',          slug: 'mark',             abbrev: 'Mar', testament: 'NT', group: 'Gospels',          groupOrder: 2,  totalChapters: 16,  tagline: 'Jesus acts with power and love',              emoji: '⚡', accentColor: 'emerald', status: 'in-progress' },
  { name: 'Luke',          slug: 'luke',             abbrev: 'Luk', testament: 'NT', group: 'Gospels',          groupOrder: 3,  totalChapters: 24,  tagline: 'Jesus came for everyone',                    emoji: '🌍', accentColor: 'emerald', status: 'in-progress' },
  { name: 'John',          slug: 'john',             abbrev: 'Joh', testament: 'NT', group: 'Gospels',          groupOrder: 4,  totalChapters: 21,  tagline: 'Jesus is the Son of God',                    emoji: '❤️', accentColor: 'emerald', status: 'in-progress' },
  // ── THE EARLY CHURCH ──────────────────────────────────────────────────────
  { name: 'Acts',          slug: 'acts',             abbrev: 'Act', testament: 'NT', group: 'The Early Church', groupOrder: 1,  totalChapters: 28,  tagline: 'The Holy Spirit grows the church',           emoji: '🔥', accentColor: 'orange',  status: 'in-progress' },
  // ── PAUL'S LETTERS ────────────────────────────────────────────────────────
  { name: 'Romans',        slug: 'romans',           abbrev: 'Rom', testament: 'NT', group: "Paul's Letters",   groupOrder: 1,  totalChapters: 16,  tagline: 'God makes us right through faith in Jesus',  emoji: '✉️', accentColor: 'blue',    status: 'in-progress' },
  { name: '1 Corinthians', slug: '1-corinthians',    abbrev: '1Co', testament: 'NT', group: "Paul's Letters",   groupOrder: 2,  totalChapters: 16,  tagline: 'How to love each other like Jesus does',    emoji: '❤️', accentColor: 'blue',    status: 'coming-soon' },
  { name: '2 Corinthians', slug: '2-corinthians',    abbrev: '2Co', testament: 'NT', group: "Paul's Letters",   groupOrder: 3,  totalChapters: 13,  tagline: "God's strength in our weakness",            emoji: '💪', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Galatians',     slug: 'galatians',        abbrev: 'Gal', testament: 'NT', group: "Paul's Letters",   groupOrder: 4,  totalChapters: 6,   tagline: 'We are free because of Jesus',              emoji: '🦅', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Ephesians',     slug: 'ephesians',        abbrev: 'Eph', testament: 'NT', group: "Paul's Letters",   groupOrder: 5,  totalChapters: 6,   tagline: 'God chose us and loves us',                 emoji: '💙', accentColor: 'blue',    status: 'in-progress' },
  { name: 'Philippians',   slug: 'philippians',      abbrev: 'Phi', testament: 'NT', group: "Paul's Letters",   groupOrder: 6,  totalChapters: 4,   tagline: 'I can do all things through Christ',        emoji: '🌟', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Colossians',    slug: 'colossians',       abbrev: 'Col', testament: 'NT', group: "Paul's Letters",   groupOrder: 7,  totalChapters: 4,   tagline: 'Jesus is above everything',                emoji: '✨', accentColor: 'blue',    status: 'coming-soon' },
  { name: '1 Thessalonians', slug: '1-thessalonians', abbrev: '1Th', testament: 'NT', group: "Paul's Letters",  groupOrder: 8,  totalChapters: 5,   tagline: 'Jesus is coming back!',                    emoji: '⭐', accentColor: 'blue',    status: 'coming-soon' },
  { name: '2 Thessalonians', slug: '2-thessalonians', abbrev: '2Th', testament: 'NT', group: "Paul's Letters",  groupOrder: 9,  totalChapters: 3,   tagline: 'Stay strong while you wait for Jesus',     emoji: '⭐', accentColor: 'blue',    status: 'coming-soon' },
  { name: '1 Timothy',     slug: '1-timothy',        abbrev: '1Ti', testament: 'NT', group: "Paul's Letters",   groupOrder: 10, totalChapters: 6,   tagline: 'How to follow Jesus as a leader',          emoji: '📖', accentColor: 'blue',    status: 'coming-soon' },
  { name: '2 Timothy',     slug: '2-timothy',        abbrev: '2Ti', testament: 'NT', group: "Paul's Letters",   groupOrder: 11, totalChapters: 4,   tagline: "Keep holding on to God's Word",           emoji: '🔥', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Titus',         slug: 'titus',            abbrev: 'Tit', testament: 'NT', group: "Paul's Letters",   groupOrder: 12, totalChapters: 3,   tagline: 'Live a beautiful life for God',            emoji: '🌿', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Philemon',      slug: 'philemon',         abbrev: 'Phm', testament: 'NT', group: "Paul's Letters",   groupOrder: 13, totalChapters: 1,   tagline: 'Forgiveness and friendship in Jesus',      emoji: '🤝', accentColor: 'blue',    status: 'coming-soon' },
  { name: 'Hebrews',       slug: 'hebrews',          abbrev: 'Heb', testament: 'NT', group: "Paul's Letters",   groupOrder: 14, totalChapters: 13,  tagline: 'Jesus is greater than everything',        emoji: '🌟', accentColor: 'amber',   status: 'coming-soon' },
  // ── GENERAL LETTERS ───────────────────────────────────────────────────────
  { name: 'James',         slug: 'james',            abbrev: 'Jam', testament: 'NT', group: 'General Letters',  groupOrder: 1,  totalChapters: 5,   tagline: 'Faith that works — love in action',        emoji: '🌱', accentColor: 'green',   status: 'in-progress' },
  { name: '1 Peter',       slug: '1-peter',          abbrev: '1Pe', testament: 'NT', group: 'General Letters',  groupOrder: 2,  totalChapters: 5,   tagline: 'Be strong when things are hard',           emoji: '🪨', accentColor: 'stone',   status: 'coming-soon' },
  { name: '2 Peter',       slug: '2-peter',          abbrev: '2Pe', testament: 'NT', group: 'General Letters',  groupOrder: 3,  totalChapters: 3,   tagline: 'Watch out for wrong teaching',             emoji: '⚠️', accentColor: 'stone',   status: 'coming-soon' },
  { name: '1 John',        slug: '1-john',           abbrev: '1Jo', testament: 'NT', group: 'General Letters',  groupOrder: 4,  totalChapters: 5,   tagline: 'God is love — and we should love too',     emoji: '❤️', accentColor: 'rose',    status: 'in-progress' },
  { name: '2 John',        slug: '2-john',           abbrev: '2Jo', testament: 'NT', group: 'General Letters',  groupOrder: 5,  totalChapters: 1,   tagline: 'Follow the truth and love each other',     emoji: '✉️', accentColor: 'stone',   status: 'coming-soon' },
  { name: '3 John',        slug: '3-john',           abbrev: '3Jo', testament: 'NT', group: 'General Letters',  groupOrder: 6,  totalChapters: 1,   tagline: "Be a good helper for God's workers",      emoji: '✉️', accentColor: 'stone',   status: 'coming-soon' },
  { name: 'Jude',          slug: 'jude',             abbrev: 'Jud', testament: 'NT', group: 'General Letters',  groupOrder: 7,  totalChapters: 1,   tagline: 'Hold on tight to the true faith',         emoji: '🛡️', accentColor: 'stone',   status: 'coming-soon' },
  // ── PROPHECY ──────────────────────────────────────────────────────────────
  { name: 'Revelation',    slug: 'revelation',       abbrev: 'Rev', testament: 'NT', group: 'Prophecy',         groupOrder: 1,  totalChapters: 22,  tagline: 'Jesus wins! The end of the story',         emoji: '🌈', accentColor: 'purple',  status: 'in-progress' },
];

export function getBibleBooksByTestament(testament: Testament): BibleBook[] {
  return BIBLE_BOOKS.filter((b) => b.testament === testament);
}

export function getGroupsForTestament(testament: Testament): string[] {
  const groups = BIBLE_BOOKS.filter((b) => b.testament === testament).map((b) => b.group);
  return [...new Set(groups)];
}
